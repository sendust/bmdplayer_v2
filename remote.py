#
#  Sendust player server remote by sendust
#  2020/12/29  Display current time while loop is running
#  2021/1/15   bug fix  command_array[s.hex()]    ->    command_array[rdata]
#  2021/2/4    ADD 'ALTCM' COMMAND
#
#

import serial
import socket
import ctypes
import configparser
import winsound
from datetime import datetime

def updatelog(text):
    logtext = str(datetime.now().strftime("[%Y/%m/%d] %H:%M:%S.%f  ")) + text
    print(logtext)
    with open('.\log\\remote_new1.log', 'a') as f1:
        f1.write(logtext + "\n")

def readini(file_ini):
    config = configparser.ConfigParser()
    config.read(file_ini)
    config.sections()
    return config


remoteconfig = readini("SBSPlayback_remote1.ini")

comport = remoteconfig["remote"]["com"]
UDP_REMOTE_IP = remoteconfig["remote"]["address"]
UDP_REMOTE_PORT = int(remoteconfig["remote"]["port"])
ctypes.windll.kernel32.SetConsoleTitleW("Player1 Remote by sendust")          ## Change console title


command_array = {
                "33bb": "[PREV]",
                "11ee": "[NEXT]",
                "22dd": "[PAUSE]",
                "24db": "[LOAD]",
                "21de": "[PLAY]",
                "21ef": "[PLAYLIST]",
                "12aa": "[ALTCM]"
                 }

command_udp = {
                "33bb": "__PREV__",
                "11ee": "__NEXT__",
                "22dd": "__PAUSE_",
                "24db": "__LOAD__",
                "21de": "__PLAY__",
                "21ef": "__PLAYL_",
                "12aa": "__ALTCM_"
              }


try:
    ser = serial.Serial(comport, 9600, timeout=0.01, parity=serial.PARITY_NONE,rtscts=1)
except SerialException:
    updatelog("port already open or exception")

       
sock = socket.socket(socket.AF_INET,  # Internet
                     socket.SOCK_DGRAM)  # UDP


updatelog("Application Start ---------")
updatelog("COMPORT IS " + comport)


count = 0
rdata = ""
while True:
    time_current = str(datetime.now().strftime("[%Y/%m/%d] %H:%M:%S.%f  "))
    print("Waiting Serial DATA from " , comport , " >>> " , time_current, end="\r")
    try:
        s = ser.read(10)
    except:
        updatelog("Error Reading Serial Port")
        updatelog("Call system exit --------------")
        quit()
    if len(s) > 0:
        rdata += s.hex()                ## append serial data
        if (rdata in command_array) and (len(rdata) == 4):
            count += 1
            str_log = str(count) + " --- [" + str(len(s)) + "] --- " + rdata + "   " + command_array[rdata] + "          "
            updatelog(str_log)
            sock.sendto(bytes(command_udp[rdata], "utf-8"), (UDP_REMOTE_IP, UDP_REMOTE_PORT))
            #print(str_log)
            #winsound.Beep(800, 200)   ## Beep sound
            rdata = ""
        else:
            str_log = str(count) + " --- [" + str(len(s)) + "] --- " + s.hex()
            updatelog(str_log)
            ##print(str_log)
    if len(rdata) > 4:                      ## discard garbage data
        rdata = ""




