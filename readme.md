## Pi Servo Tester  - Pi Servo Checker

The Pi Servo Tester generates servo pulses with a duration of 0.5 ms to 2.5 ms and a cycle rate of 50 ms. In model making it is used for functional testing of servos. 
The Servo Checker consists of a Raspberry Pi with a 16-channel PWM module and a smart phone App, which takes over the control. 
The complete documentation of this configuration can be found at "https://github.com/monbera/TelDaControl". The Raspberry receiver software is taken over completely and only needs to be adapted with regard to the configuration. The smart phone application was developed especially for this application. 
Translated with www.DeepL.com/Translator

## Step 1

The following materials are required: 
- Raspberry Pi Zero WH
- 16 Channel PWM Bonnet 
- Power supply 5V/1A 
- Smartphone

## Step 2

Install the ‘ServoChecker’ APK file on your smartphone. The installation of external sources must be allowed in the security settings.

## Step 3

Chapter 3.2.2.5 "Preparation of the Raspberry Pi" [1] describes the necessary steps for commissioning the Raspberry Pi. Only the file "rcmain.py" has to be adapted. Do not forget to solder a bridge on the Servo+ PWM Bonnet Board as shown in Figure 5 [1]. Plug together with the Raspberry Pi and commission according to the chapter 3.2.2.5.3 ‘First Tes’t [1]. 

## Step 4
On the mobile phone the data connection to the provider should be switched off and the hot spot function of the smartphone should be switched on. The hot spot configuration must match to the data of the "wpa_supplicant.conf" on the Raspberry Pi. 
After the 'ServoChecker' app has been started, the communication indicator lights up red. Now the Servo Tester (Rpi) can be switched on. After starting the communication  the status of the indicator changes to 'green'.  Now you can test servos on the channels 0..14 Servos. 

[1]	https://github.com/monbera/TelDaControl




