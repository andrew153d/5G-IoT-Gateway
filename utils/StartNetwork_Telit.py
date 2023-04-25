#!/usr/bin/python

import serial
import time
ser = serial.Serial("/dev/ttyUSB2",115200)

rec_buff = ''

def send_at(command,back,timeout):
        rec_buff = ''
        ser.write((command+'\r\n').encode())
        time.sleep(timeout)
        if ser.inWaiting():
                time.sleep(0.01 )
                rec_buff = ser.read(ser.inWaiting())
        if back not in rec_buff.decode():
                print(command + ' ERROR')
                print(command + ' back:\t' + rec_buff.decode())
                return 0
        else:
                print(rec_buff.decode())
                return 1

try:
        send_at('AT+SIMCOMATI','OK',1)
        send_at('AT+CSQ','OK',1)
        send_at('AT+CPSI?','OK',1)
        send_at('AT+CNMP=2','OK',1)
        send_at('AT+CUSBCFG=USBID,1E0E,9011 ','OK',1)
        time.sleep(20)
except :
        ser.close()

