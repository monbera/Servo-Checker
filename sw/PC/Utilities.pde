/*-------------------------------------------------------------------------------
 Name:        Servo Tester for PC 
 Purpose:     Testing of servos at channel 0..14 and switches at channel 15
 
 Author:      Bernd Hinze
 
 Created:     03.05.2019
 Copyright:   (c) Bernd Hinze 2019
 Licence:     MIT see https://opensource.org/licenses/MIT
 ------------------------------------------------------------------------------
 */
 
boolean SIM = false; 

void settings(){
  size(800,400);
}

/* -----------------------------------------------------------------------------
 Dertermines if a finger or the mouse is over the area given by the 
 coordinates and the radius - PC version
 ---------------------------------------------------------------------------------
 */
int overCircle(int x, int y, int radius) {
  int result = 0; // means false 
  int disX = x - mouseX;
  int disY = y - mouseY;

  if (sqrt(sq(disX) + sq(disY)) < radius ) {
    result = 1;
  } else {
    result = 0;
  }
  return result;
}


/* -----------------------------------------------------------------------------
 Dertermines if a finger or the mouse is touching the scree and change the state of 
 switches 
 ---------------------------------------------------------------------------------
 */
void mousePressed() { 
  if (S1.overS() &&  (ip_received == true)) {
    if (udp.send(S1.getSval(), ip, port) == false) {
      ip_received = false;
    }
  }
  if (S2.overS() &&  (ip_received == true)) {
    if (udp.send(S2.getSval(), ip, port) == false) {
      ip_received = false;
    }
  }
  if (C.overT()) {
    L2.setChannel(C.getChannel());
  }
}