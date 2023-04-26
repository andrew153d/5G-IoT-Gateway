#!/usr/bin/python

import serial
import time
import sys

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
        command = sys.argv[1]  # get the command from the command-line argument
        send_at(command,'OK',1)
except Exception as e:
        print("Error: ", e)
finally:
        ser.close()