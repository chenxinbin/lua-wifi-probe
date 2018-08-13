# lua-wifi-probe (beta version)
a smart wifi probe base nodemcu on ESP8266

Work Flow:
1. connect the wifi , rsync the datetime;
2. switch a channel(1-15) every second for scanning
3. after 3 loop, connect the wifi again, send data with UDP
4. go step 2 again. 

#Develop Environment
ESPlorer (The IDE for DEV, upload lua scripts)


About firmware
the two files in the folder firmware is built after some changes:
1. change dstmac and srcmac. the official script is wrong.
2. I try to catch all frames , not only for management frame. But failed, I will try again...


If you have some question, please contact me xinbin.chen#gmail.com