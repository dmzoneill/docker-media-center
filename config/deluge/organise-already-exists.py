#!/usr/bin/python

import os
import re 
import subprocess

dir = "logs"

for filename in os.listdir(dir):
    if filename.startswith("organise") and filename.endswith(".log"): 
        file = open(dir + "/" + filename, "r")
        content = file.read()
        already_exists = re.findall(r"Skipped \[(.*?)\] because \[(.*?)\] already exists", content)
        if len(already_exists) > 0:           

            result1 = subprocess.run(['mediainfo', already_exists[0][0]], stdout=subprocess.PIPE)
            out1 = result1.stdout.decode('utf-8')
            width1 = re.findall(r"Width.*?: (.*?) pixels", out1)
            height1 = re.findall(r"Height.*?: (.*?) pixels", out1)
            
            result2 = subprocess.run(['mediainfo', already_exists[0][1]], stdout=subprocess.PIPE)
            out2 = result2.stdout.decode('utf-8')
            width2 = re.findall(r"Width.*?: (.*?) pixels", out2)
            height2 = re.findall(r"Height.*?: (.*?) pixels", out2)

            if(len(width1) > 0 and len(width2) > 0):
                int_w1 = int(width1[0].replace(" ", ""))
                int_h1 = int(height1[0].replace(" ", ""))
                int_w2 = int(width2[0].replace(" ", ""))
                int_h2 = int(height2[0].replace(" ", ""))

                if(int_w1 > int_w2 or int_h1 > int_h2):
                    print(already_exists)
                    print(width1[0])
                    print(height1[0])
                    print(width2[0])
                    print(height2[0])
                    os.system("cp \"" + already_exists[0][0] + "\" \"" + already_exists[0][1] + "\"")
