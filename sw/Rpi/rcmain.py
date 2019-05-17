#! /usr/bin/env python
#-------------------------------------------------------------------------------
# Name:        Remote Control Receiver 
# Purpose:     Receiving remote control commands, controlling 
#              seros, H-Bridges and digital outputs using a PCA9685 board     
# Author:      Bernd Hinze
#
# Created:     10.04.2019
# Copyright:   (c) Bernd Hinze 2019
# Licence:     MIT see https://opensource.org/licenses/MIT
# -----------------------------------------------------------------------------
import time
from rcapp import PWM_Controller, UDP_Client, Observer, SIM


def main():
    # Configuration general prototype
    # Channel 0..14: Servos
    # Channel 15: Digital Output
    if not SIM:
        time.sleep(10)  
    L298Channels = []
    DIOs = [15]
    Inverted = []  
    SC = PWM_Controller(0.5, 2.5, 50, L298Channels, DIOs, Inverted)
    SC.fail_safe()
    S = UDP_Client(SC,'', 6000, 6100, 10, "ServoChecker")
    O = Observer(SC, 30.0, "ServoChecker")


if __name__ == '__main__':
    main()
