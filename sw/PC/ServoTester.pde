/*-------------------------------------------------------------------------------
 Name:        Servo Tester for PC and Android
 Purpose:     Testing of servos at channel 0..14 and switches at channel 15
 
 Author:      Bernd Hinze
 
 Created:     03.05.2019
 Copyright:   (c) Bernd Hinze 2019
 Licence:     MIT see https://opensource.org/licenses/MIT
 ------------------------------------------------------------------------------
 */
import hypermedia.net.*;
UDP udp;
LeverT L2;
SwitchApp S1;
Switch S2;
Channel C;
Indicator ICom;

String ip       = "";  // the remote IP address
int port        = 6100;    // the destination port
int tms_received = millis();
int tms_received_tout = 5 * 1000; // 20s
boolean ip_received = false; 
String ID = "";            // receiver ID 
String [] CodeTable  =  {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?"}; 


void setup() {
  if (SIM) {
    ip  = "127.0.0.1";  // the remote IP address
    ip_received = true;
  }
  orientation(LANDSCAPE); 
  background (#63aad0);
  L2 = new LeverT (int(height*0.6), int(width*0.3), int(width*0.7), int (50), 0);
  S1 = new SwitchApp(int(height * 0.04), int(width * 0.08), int(height * 0.15), 15, 100); 
  S2 = new Switch(int(height * 0.04), int(width * 0.16), int(height * 0.15), 15, 255);
  C = new Channel(int(width * 0.5), int(height * 0.85), "L");
  ICom = new Indicator(ID, "No Device", 0.95, 0.10);
  PFont Ltrimf;
  Ltrimf = createFont("Arial-BoldMT-16.vlw", 16);   
  textFont(Ltrimf, int(height * 0.04));
  udp = new UDP (this, 6000);
  udp.listen( true );
}


void draw() {
  background (#63aad0);
  displayName();
  L2.display();
  S1.display();
  S2.display();
  C.display();
  // End Adaptation 
  ICom.display(ip_received);
  if (ip_received == true) {
    try {
      udp.send((L2.getVal(L2.px)), ip, port);
      println(L2.getVal(L2.px));
    }
    catch (Exception e) {
    }
  }
  if (SIM ==false) {
    if ((millis() - tms_received) > tms_received_tout) {
      ip_received = false;
    }
  }
}

void displayName() { 
  textAlign(CENTER);
  fill(80);
  text("Servotester / Servo Checker", width*0.5, height*0.1);
}


/* -------------------------------------------------------------------------
 The function draws the current state of the connction and the receiver ID 
 on the right corner of the screen.
 ----------------------------------------------------------------------------   
 */
class Indicator {
  int tx, ty, ex, ey, ed;
  String gr, rd;

  Indicator(String green, String red, float x, float y) {
    ex = int(width * x);
    ey = int(height * y);
    ed = int(height * 0.05);
    tx = int(width * (x - 0.03));
    ty = int(height * (y + 0.015)); 
    gr = green;
    rd = red;
  }

  void display(boolean state) {
    textAlign(RIGHT);
    if (state == true) {
      fill(#04C602);
      ellipse(ex, ey, ed, ed);  
      fill(80);
      text(gr, tx, ty);
    } else {
      fill(#FF0000);
      ellipse(ex, ey, ed, ed);
      fill(80);
      text(rd, tx, ty);
    }
  }
}

/* ----------------------------------------------------------------------------------
 That is the default method of the UDP library for listening. The receiver transmits 
 cyclic every second the following string decoded to the Application: "ID@IP". 
 Example "RC#001@192.168.43.3". It will be splitted and checked whether it is an IP 
 from an local network. The variable 'ip_received' and the timestamp is set.
 ------------------------------------------------------------------------------------  
 */
void receive(byte[] data) {  
  String message = new String( data );
  String[] parts = split(message, "@");
  ID = parts[0]; 
  String[] ip_parts = split(parts[1], ".");
  // checking wether it is probably a IP adress
  if ((int(ip_parts[0])==192) && (int(ip_parts[1])==168)) {
    ip = parts[1];
    ip_received = true;
    tms_received = millis();
  }
}

/* -----------------------------------------------------------------------------
 Creates two strings from a decimal value with an input limitation from 0 to 255. 
 ---------------------------------------------------------------------------------
 */
String int2str(int inp) {
  return (CodeTable[inp /16] + CodeTable[inp %16]);
}

/* ---------------------------------------------------------------------
 This class implements the horizontal control lever. 
 Parameter:
 cx: distance to the left screen border
 clim_pos_low: distance of the top guideway end to the top border
 clim_pos_high: distance of the lower guideway end to the top border
 cdefault_Pos: default Lever position 0..100 per cent 
 channel: channel number (0..15) of the PWM module   
 ------------------------------------------------------------------------ */
class LeverT {
  int tx, ty, lim_pos_low, lim_pos_high, center_pos, cdefault_Pos, tvy;
  int d, rgrid, px, py, dx, backlim_high, backlim_low, vh, vw, vr;
  int valIdx = 0, ch, dist;
  String StrCh = "", tVal;
  int [] ValMap;  

  LeverT(int ct, int clim_pos_low, int clim_pos_high, int cdefault_Pos, int channel) {
    ch = channel;
    lim_pos_low = clim_pos_low;
    lim_pos_high = clim_pos_high;
    center_pos = ((lim_pos_high - lim_pos_low) * cdefault_Pos/100) + lim_pos_low;
    backlim_high =  center_pos + (lim_pos_high - lim_pos_low)/3;
    backlim_low =   center_pos - (lim_pos_high - lim_pos_low)/3;
    d = int(height * 0.2);
    rgrid = int(d* 0.75);  
    StrCh = "Channel";
    py = ct;
    px = center_pos;
    ty = int(py + py*0.3);
    tx = center_pos; 
    tvy = int(py - py*0.5);
    vh = int(height * 0.1);
    vw = vh * 3; 
    vr = int(vh*0.15);
    //LeverHandle(px, py);
    ValMap = new int [int(lim_pos_high)+1]; 
    createValMap(int(lim_pos_low), int(lim_pos_high));
  }

  void display() { 
    stroke(90);
    strokeWeight(8);
    line (lim_pos_low, py, lim_pos_high, py ); 
    fill(80); 
    textAlign(CENTER);
    text(StrCh, tx, ty);
    println( px);
    valIdx = overCircle(px, py, rgrid);
    if (valIdx != 0) {
      px = constrain((mouseX), lim_pos_low, lim_pos_high);
    } else {
      dist = abs(center_pos - px);
      if ((px > int(center_pos)) && (px < backlim_high)) {
        if (dist > 20) {
          px -= 3;
        } else { 
          px -= 1;
        }
      }
      if ((px < int(center_pos)) && (px > backlim_low)) {
        if (dist > 20) {
          px += 3;
        } else { 
          px += 1;
        }
      }
    }   
    LeverHandle(px, py); 
    displayImpVal();
  }

  void LeverHandle(int X_pos, int Y_pos ) {
    strokeWeight(2);
    fill(#79c72e);
    ellipse(X_pos, Y_pos, d, d);
  }

  /*
   Creates a table that maps the geografical position of the 
   lever to the interface value range needed for the 
   PWM device driver interface 0..254 (miniSSC protocol)
   */
  void createValMap(int min, int max) {
    for (int i = min; i < max+1; i++) { 
      ValMap [i] = round(map(i, max, min, 254, 0));    
      //println (i, ValMap[i]);
    }
  }

  void displayImpVal() {
    fill(#FAE988);
    rectMode(CENTER);
    rect(tx, tvy-vr, vw, vh, vr);
    rectMode(CORNER);
    tVal = nf(getDisplVal(px), 1, 2);
    fill(80); 
    textAlign(CENTER);
    text(tVal + " ms", tx, tvy);
  }

  float getDisplVal(int setVal) {
    // 0 = 0,5 ms , 254 = 2,5 ms  fix configuration at the rpi tester    
    return (0.5 + ValMap[setVal] / 254.0 * 2.0);
  }

  /**
   Creates the telegramm to transfer coded values for 
   header : 255
   ch: 0..15
   ValMap[setVal]: 0..254
   */
  String getVal(int setVal) {
    return (int2str(255) + int2str(ch) + int2str(ValMap[setVal]));
  }

  void setChannel(int cha) {
    ch = cha;
  }
}


/* --------------------------------------------------------------------------
 This class draws a switsch with two positions On - Off
 r: radius
 cx: distance to the left border of the screen
 cy: distance to the top border of the screen
 channel: channel number (0..15) of the PWM module
 ----------------------------------------------------------------------------
 */
class Switch {
  int SWh, SWr, SWx, SWy, SWOff, SWOn, SWd, pSWPos, SWytOn, SWytOff, SWgrid, SWhdr;
  int valIdx = 0, SWCh;
  String StrCh = "";

  Switch ( int r, int cx, int cy, int channel, int hdr) {
    SWr = r; 
    SWd = 2 * r;
    SWh = 4 * SWr; 
    SWx = cx;
    SWy = cy;
    SWytOn = SWy + int(3.5 * SWr); 
    SWytOff = SWy - int(2.5 * SWr);
    SWOff = SWy - SWr; 
    SWOn = SWy + SWr; 
    SWgrid = int(1.5 * SWr);
    pSWPos = SWOff;
    SWCh = channel;
    SWhdr = hdr;
    StrCh = "C"+ str(SWCh);
  }

  void display() {
    rectMode(CENTER);
    stroke(75);
    fill(110); 
    rect(SWx, SWy, SWr, SWh, 1.5*SWr);  // base plate 
    drawLabel();
    if (pSWPos == SWOff) {
      fill(160);
    } else {
      fill(20, 150, 20);
    }
    ellipse (SWx, pSWPos, SWd, SWd);
    rectMode(CORNER);
  }

  void drawLabel() {
    fill(80); 
    textAlign(CENTER);
    text(StrCh, SWx, SWytOn); 
    text("", SWx, SWytOff);
  }

  String getSval() {
    if (pSWPos == SWOff) {  
      return (int2str(SWhdr) + int2str(SWCh) + int2str(0));
    } else {
      return (int2str(SWhdr) + int2str(SWCh) + int2str(254));
    }
  }

  boolean overS() {
    boolean result = false; 
    if ((overCircle(SWx, SWOff, SWgrid)) != 0){
      pSWPos = SWOff;
      result = true;
    }
    if ((overCircle(SWx, SWOn, SWgrid)) != 0){
      pSWPos = SWOn;
      result = true;
    }
    return result;
  }
}  

/* --------------------------------------------------------------------------
 This class is an extention of the 'Switch' class and overwrites 
 the default position and the knob labels
 With the header configuration of hdr = 100 it can power down
 the receiver.
 ----------------------------------------------------------------------------
 */
class SwitchApp extends Switch {

  SwitchApp ( int r, int cx, int cy, int channel, int hdr) {
    super (r, cx, cy, channel, hdr); 
    pSWPos = SWOn;
  }

  void drawLabel() {
    fill(80); 
    textAlign(CENTER);
    text("ON", SWx, SWytOn); 
    text("OFF", SWx, SWytOff);
  }
}


/*-------------------------------------------------------------------------
 This sclass draws the trim buttons and an indication 
 area to depict the current trim value. 
 ----------------------------------------------------------------------------
 */
class Channel {
  int r = int(height * 0.08), centerX, centerY, x1, x2, y1, y2, dist;
  int  valIdx = 0, ichannel; 
  String orientation;  //  "L" | "P"

  Channel (int cX, int cY, String orientation) {
    ichannel = 0;
    centerX = cX;
    centerY = cY; 
    //PFont Ltrimf;
    //Ltrimf = createFont("Arial-BoldMT-16.vlw", 16);   
    //textFont(Ltrimf, r/2);
    dist = int(height * 0.2);
    if (orientation == "P") {
      x1 = centerX;  
      x2 = centerX; 
      y1 = centerY - dist;
      y2 = centerY + dist;
    } else {
      y1 = centerY;  
      y2 = centerY; 
      x1 = centerX - dist;
      x2 = centerX + dist;
    }
    displayVal();
  }

  void display() {
    stroke(75);
    fill(100); 
    ellipse(x1, y1, r, r);
    ellipse(x2, y2, r, r);
    displayVal();
  }  

  void displayVal() {
    rect (centerX-r*0.5, centerY-r/2, r, r);
    fill(200);
    textAlign(CENTER);
    text(str(ichannel), centerX, centerY+r*0.2);
  }

  boolean overT() {
    boolean result = false;
    if ((overCircle(x1, y1, r)) != 0) {
      ichannel = ichannel - 1;
      ichannel = constrain (ichannel, 0, 14);
      result = true;
    }
    if ((overCircle(x2, y2, r)) != 0){
      ichannel = ichannel + 1;
      ichannel = constrain (ichannel, 0, 14);
      result = true;
    }
    return result;
  }

  int getChannel() {
    return ichannel;
  }
}
