#!/usr/bin/python3
import serial
import time
import struct

ser = serial.Serial('/dev/ttyUSB0', 115200)

time.sleep(3)

# get ssid
while True:
    ser.write(b'\x01\x00\x00\x00\xB0\x00\x01')
    time.sleep(1)

    ser.write(b'\x00\x01\x02\x00\xB0\x00')
    while ser.in_waiting < 2:
        pass
    time.sleep(1)
    available = struct.unpack('h', ser.read(ser.in_waiting))[0]
    print('available: ', available)



    ser.write(b'\x00\x01\x04\x00\xB0\x00')
    while ser.in_waiting < 2:
        pass
    time.sleep(1)
    print('position: ', ser.read(ser.in_waiting))

    value = b''

    for i in range(available):
        ser.write(b'\x00\x00\x00\x00\xB0\x00')
        while ser.in_waiting < 1:
            pass
        value += ser.read(ser.in_waiting)
    print('value: ', value)