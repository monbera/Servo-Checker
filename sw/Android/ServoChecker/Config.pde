/*-------------------------------------------------------------------------------
 Name:        Mode dependig routines for Android app 
 Purpose:     Testing of servos at channel 0..14 and switches at channel 15
 
 Author:      Bernd Hinze
 
 Created:     03.05.2019
 Copyright:   (c) Bernd Hinze 2019
 Licence:     MIT see https://opensource.org/licenses/MIT
 ------------------------------------------------------------------------------
 */

boolean SIM = false; 

void settings(){
  fullScreen();
}

/* -----------------------------------------------------------------------------
   Dertermines if a finger is over the area given by the 
   coordinates and the radius - Android version
---------------------------------------------------------------------------------
*/
  int overCircle(int x, int y, int radius) 
  {
   int valIdx = 0; 
   for (int i = 0;  i < touches.length; i++){
    int disX = x - int(touches[i].x);
    int disY = y - int(touches[i].y);
    if ((sqrt(sq(disX) + sq(disY)) < radius ) 
       && (valIdx == 0)){
        valIdx = i + 1 ;  // caused 0 is not valid, shifting
       }
   }
   return valIdx;
  }


/* -----------------------------------------------------------------------------
 Dertermines if a finger or the mouse is touching the scree and change the state of 
 switches 
 ---------------------------------------------------------------------------------
 */
void touchStarted() 
{ 
  // Start adaptation required  
  if ((ICom.err_state() & ERR_IP) == NO_ERR) // ip valid
  {
    if (S1.overS())
    {
      if (udp.send(S1.getSval(), ip, port) == false)
      {
        ICom.set_err_state(ERR_UDP);      
      }
    }
    if (S2.overS())
    {
      if (udp.send(S2.getSval(), ip, port) == false)
      {
      ICom.set_err_state(ERR_UDP);
      }
    }
    if (C.overT()) 
    {
      L2.setChannel(C.getChannel());
    }
  }
}
