#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Copyright © 2013 Your Name <dot_baiki@yahoo.com>
This work is free. You can redistribute it and/or modify it under the
terms of the Do What The Fuck You Want To Public License, Version 2,
as published by Sam Hocevar. See the COPYING file for more details.
'''

import os, glob, time, signal, sys

version      = 0.54
new_temp_c   = 0.0
old_temp_c   = 0.0
count        = 0
ausgabedatei = 'data/messwerte_' + str(time.time()) + '.csv'

try:
    datei = open(ausgabedatei, 'a')
except:
    print 'File access failed. Programm terminated.'
    sys.exit(0)

os.system('sudo modprobe w1-gpio')
os.system('sudo modprobe w1-therm')

base_dir      = '/sys/bus/w1/devices/'
device_folder = glob.glob(base_dir + '28*')[0]
device_file   = device_folder + '/w1_slave'

def read_temp_raw():
    f = open(device_file, 'r')
    lines = f.readlines()
    f.close()
    return lines

def read_temp():
    lines = read_temp_raw()
    while lines[0].strip()[-3:] != 'YES':
        time.sleep(0.2)
        lines = read_temp_raw()
    equals_pos = lines[1].find('t=')
    if equals_pos != -1:
        temp_string = lines[1][equals_pos+2:]
        temp_c = float(temp_string) / 1000.0
        return temp_c

def signal_handler(signal, frame):
    print '\nCTRL+C received. Programm terminated.'
    datei.close()
    sys.exit(0)

signal.signal(signal.SIGINT, signal_handler)

os.system('clear')
print "Baiki's Thermometer v" + str(version)
print "(press CTRL+C to quit)\n"

while True:
    new_temp_c = round(read_temp(), 1)
    if new_temp_c != old_temp_c:
        loctime = time.localtime()
        j, m, t, std, min, sec = loctime[0:6]
        datum = "{0:04d}.{1:02d}.{2:02d}".format(j, m, t)
        zeit = "{0:02d}:{1:02d}:{2:02d}".format(std, min, sec)
        print '(' + datum, zeit + ') ' + str(new_temp_c) + '°C'
        datei.write(datum + ',' + zeit + ',' + str(new_temp_c) + "\n")
        count += 1
        if count >= 5:
            datei.close()
            datei = open(ausgabedatei, 'a')
            count = 0
        old_temp_c = new_temp_c
        time.sleep(10)
