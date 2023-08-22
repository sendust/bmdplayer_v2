#
#   Caspar channel infomation reader for v2.1 by sendust
#   Lastedit : 2021/3/9
#    
#    send "info 1-1" command to Caspar Server and Analysis channel, layer information
#    2020/12/27 AddSingle instance checker 
#    2021/3/6   Modified for v2.1 
#       info 1-1 reports invalid left frames
#       [data store seek]
#       [data store length]  command must be executed before load clip
#    2021/3/8
#       seek, length --> mark_in, mark_out
#    2021/3/9
#       compatible with v2.3 (path_foreground, name_foreground, path_background, name_background)




import traceback
import socket
import threading
import xml.etree.ElementTree as ET
import time
import ctypes
import sys
import os
import logging
import portalocker              # manual installation requested
import configparser
# from timecode_smpte import frames_to_timecode   # timecode_smpte.py req.
from datetime import datetime


def LOG_insert(file, format, text, level):
    infoLog = logging.FileHandler(file)
    infoLog.setFormatter(format)
    logger = logging.getLogger(file)
    logger.setLevel(level)
    
    if not logger.handlers:
        logger.addHandler(infoLog)
        if (level == logging.INFO):
            logger.info(text)
        if (level == logging.ERROR):
            logger.error(text)
        if (level == logging.WARNING):
            logger.warning(text)

    infoLog.close()
    logger.removeHandler(infoLog)

    return

def updatelog2(text):
    formatLOG = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
    LOG_insert(".\info_reader.log", formatLOG, text, logging.INFO)
    print(text)
    return


def updatelog(text):
    logtext = str(datetime.now().strftime("[%Y/%m/%d] %H:%M:%S.%f  ")) + text
    print(logtext)
    with open('.\log\\info_reader.log', 'a') as f1:
        f1.write(logtext + "\n")

def readini(file_ini):
    config = configparser.ConfigParser()
    config.read(file_ini)
    config.sections()
    return config
    


def frames_to_timecode(frames):
    # frame to smpte time code  fot NTSC drop frame
    framerate = 29.97
    fps_int = int(framerate + 0.5)      # round up framerate
    sizeBigCycle = 17982			    # every 10 minute, there is no tc drop
    sizeWeeCycle = 1798			        # every  1 minute, there is tc drop
    numBigCycles = frames // sizeBigCycle
    tailFrames = frames - (numBigCycles * sizeBigCycle)
	
    if (tailFrames < (sizeWeeCycle + 2)):
        numWeeCycles = 1
    else:
        numWeeCycles = (tailFrames - 2) // sizeWeeCycle + 1
	
    numSkips1 = numWeeCycles - 1
    numSkips2 = numBigCycles * 9
    numSkips3 = numSkips1 + numSkips2
    framesSkipped = numSkips3 * 2
    adjustedFrames = frames + framesSkipped
	
    frame = int(adjustedFrames) % fps_int
    seconds = (int(adjustedFrames) // fps_int) % 60
    minutes = (int(adjustedFrames) // (fps_int * 60)) %  60
    hours = int(adjustedFrames) // (fps_int * 3600)
	
   
    result = "{h:01d}:{m:02d}:{s:02d};{f:02d}"
    return result.format(h = hours, m = minutes, s = seconds, f = frame)
    

class Caspar_info:

    def __init__(self):
        updatelog("Creating Caspar info object")
        max_duration = 86400
        self.max_duration = max_duration
        self.length = max_duration
        self.data = {}
        self.paused = ""
        self.time_run_old = 0
        self.time_run = 0
        self.position_run = 0
        
        self.clip0 = 0
        self.clip1 = max_duration
        self.time0 = 0
        self.time1 = max_duration
        
        
        casparconfig = readini("sendust_player1.ini")
        self.media_path = casparconfig["caspar"]["caspar_mediapath"]
        
    def get_time_rem(self):
        
        time_rem = 0
        return time_rem



def checkif_nodeis_null(obj, ret_value):
    if obj == None:
        return ret_value
    else:
        return obj.text


def checkif_nodeis_null2(obj, ret_value):
    if obj:
        return obj.text
    else:
        return ret_value


def printobjectlist(obj):
    list = ""
    for att in dir(obj):
        if not att.startswith('__'):
            try:
                print(att, "----->" ,  getattr(obj, att))
                list = str(att) + "  ----->  " + str(getattr(obj, att))
            except Exception as e:
                print(str(e))
                
    return list

        
def analysis_info(xml):
    global caspar_info
    xml = xml.split("\r\n")
    # print("info parsing result is " + xml[1])
    try:
        root = ET.fromstring(xml[1])            # remove header ("INFO OK")
    except:
        updatelog("XML is damaged ...")
        return
 
    print("root is " , root)

    if root == None:
        print("XML des not have root !!")
        return
        
    caspar_info.get_time_rem()
    
    print("Recv Length is [%d]" % (len(xml[1])))
    print("print object --------------------------")
    printobjectlist(caspar_info)
    print("Finish print --------------------------")
        
    try:
        
        node = root.findall('.//foreground/producer/fps')
        if node:
            caspar_info.foreground_fps0_channel = checkif_nodeis_null(node[0], 0)
        else:
            caspar_info.foreground_fps0_channel = -1



        node = root.findall('.//foreground/producer/file-frame-number')
        if node:
            caspar_info.foreground_file_frame_number = checkif_nodeis_null(node[0], "")
        else:
            caspar_info.foreground_file_frame_number = 0


        node = root.findall('.//foreground/producer/file-nb-frames')
        if node:
            caspar_info.file_nb_frames = checkif_nodeis_null(node[0], "")
        else:
            caspar_info.file_nb_frames = 1


        node = root.find('.//foreground/producer/filename')
        caspar_info.path_foreground = checkif_nodeis_null(node, "")
        caspar_info.path_foreground = caspar_info.path_foreground.replace("/", "\\")
        caspar_info.path_foreground = caspar_info.path_foreground.replace("\\\\\\", "\\")
        
       
        node = root.find('.//background/producer/filename')
        caspar_info.path_background = checkif_nodeis_null(node, "")
        caspar_info.path_background = caspar_info.path_background.replace("/", "\\")
        caspar_info.path_background = caspar_info.path_background.replace("\\\\\\", "\\")
        
        
        
        node =  root.find('.//foreground/producer/loop')
        caspar_info.loop = checkif_nodeis_null(node, "")

        
        node =  root.find('.//foreground/producer/type')
        caspar_info.producer_foreground = checkif_nodeis_null(node, "")


    except Exception as e:
        updatelog("Raise exception while decoding xml : " + str(e))
        updatelog(traceback.format_exc())
        updatelog(xml)

        
def get_data(data, text):       # Retrieved data pushed by sendust player UI
    global caspar_info
    print("name_background = " + caspar_info.path_background)
    if (len(caspar_info.path_background)):       # There is background file
        print("Background is loaded !!")
        return
    rdata = text.split("\r\n")
    if (rdata[0] == "201 DATA RETRIEVE OK"):
        #print("Retrieved data [" + data + "]  =  " + rdata[1])
        caspar_info.data[data] = rdata[1]
        #print("===>>> " + data + " = " + caspar_info.data[data])
    else:
        print("Fail to retrieve data")

def analysis_data():
    global caspar_info
    try:                    # interest values acquired by calculation
        if ( int(caspar_info.data["mark_out"]) < int(caspar_info.foreground_file_frame_number)):
            print("file frame number is beyond mark_out, adjust mark_out point")
            caspar_info.data["mark_out"] = caspar_info.foreground_file_frame_number
        caspar_info.frames_left = int(caspar_info.data["mark_out"]) - int(caspar_info.foreground_file_frame_number)
        caspar_info.time_run = (int(caspar_info.foreground_file_frame_number) - int(caspar_info.data["mark_in"])) / 29.97
        caspar_info.time_rem = (int(caspar_info.data["mark_out"]) - int(caspar_info.foreground_file_frame_number)) / 29.97
        caspar_info.smpte_rem = frames_to_timecode(caspar_info.time_rem * 29.97)
        caspar_info.smpte_run = frames_to_timecode(caspar_info.time_run * 29.97)
        caspar_info.smpte_dur = frames_to_timecode(int(caspar_info.data["mark_out"]) - int(caspar_info.data["mark_in"]))
        caspar_info.clip0 = int(caspar_info.data["mark_in"]) / 29.97
        caspar_info.clip1 = (int(caspar_info.data["mark_out"]) - int(caspar_info.data["mark_in"])) / 29.97
        caspar_info.time0 = int(caspar_info.foreground_file_frame_number) / 29.97
        caspar_info.time1 = int(caspar_info.file_nb_frames) / 29.97
        
        caspar_info.name_foreground = caspar_info.path_foreground.replace(caspar_info.media_path, "")
        caspar_info.name_foreground = caspar_info.name_foreground.replace("\\", "/")
        caspar_info.name_foreground = caspar_info.name_foreground.replace("///", "/")
        
        caspar_info.name_background = caspar_info.path_background.replace(caspar_info.media_path, "")
        caspar_info.name_background = caspar_info.name_background.replace("\\", "/")
        caspar_info.name_background = caspar_info.name_background.replace("///", "/")

        if caspar_info.time_run:
            caspar_info.position_run = float(caspar_info.time_run) / (float(caspar_info.time_run) + float(caspar_info.time_rem))
        else:
            caspar_info.position_run = 0
        if (caspar_info.foreground_file_frame_number == caspar_info.foreground_file_frame_number_old):
            caspar_info.paused = "true"
        else:
            caspar_info.paused = "false"
        
    except Exception as e:
        updatelog("Error while analysis info data" + str(e))    
    caspar_info.time_tick = time.perf_counter()
    caspar_info.foreground_file_frame_number_old = caspar_info.foreground_file_frame_number    

class Amcp:
    sock = 0
    
    def __init__(self, host, port):
        updatelog("Creating AMCP object....")
        self.host = host
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        
        try:
            self.sock.connect((self.host, self.port))
            #self.sock.setblocking(0)
            self.sock.sendall(bytes("LOG LEVEL warning\r\n", "utf-8"))
            received = str(self.sock.recv(8000), "utf-8")
            
        except Exception as e:
            updatelog("Error creating socket" + str(e))

    def sendinfo(self, channel):
        try:
            data = "info " + str(channel) + "-1\r\n"
            print("Send info command to caspar  // " + data)
            result = self.sock.sendall(bytes(data, "utf-8"))
            print("Send info command result = " , result)
            received = str(self.sock.recv(8000), "utf-8")
            analysis_info(received)
            
            data = "data retrieve mark_in\r\n"
            #print("Send command /// " + data)
            result = self.sock.sendall(bytes(data, "utf-8"))
            received = str(self.sock.recv(8000), "utf-8")
            #print("Retrieved seek data is " + received)
            get_data("mark_in", received)
            
            data = "data retrieve mark_out\r\n"
            #print("Send command /// " + data)
            result = self.sock.sendall(bytes(data, "utf-8"))
            received = str(self.sock.recv(8000), "utf-8")
            #print("Retrieved length data is " + received)
            get_data("mark_out", received)
            
            analysis_data()
            threading.Timer(0.05, self.sendinfo, [channel]).start()
            #print("Received: {}".format(received))
        except Exception as e:
            updatelog(printobjectlist(e))
            updatelog("Get info warning !! Error sending command" + str(e))

        
    def recvinfo(self):
        pass
    
    def recvinfo2(self):       # Depricated 
        print("Recv info started....")
        try:    
            received = str(self.sock.recv(8000), "utf-8")
            analysis_info(received)
            threading.Timer(0.08, self.recvinfo).start()
        except Exception as e:
            updatelog("Error recving info data" + str(e))
        
    def __del__(self):
        updatelog("Destroy AMCP object")
        self.close()
        
    def close(self):
        try:
            self.sock.close()
        except Exception as e:
            updatelog("Error while closing socket" + str(e))


class Watch_dog:

    def __init__(self):
        self.tick_old = -1
        updatelog("Creating Watchdog object")
        
    def run_dog(self):
        global caspar_info
        global amcp
        host = amcp.host
        port = amcp.port
        print("###### Watch dog tick comparison %f , %f #######" %(caspar_info.time_tick,  self.tick_old))
        if caspar_info.time_tick == self.tick_old:
            updatelog("Watch dog warning !! Server not response")
            try:
                amcp.close()
                amcp = Amcp(host, port)
                amcp.sendinfo(1)
                # amcp.recvinfo()
            except Exception as e:
                updatelog("Raise exception while creating amcp" + str(e))
                    
        self.tick_old = caspar_info.time_tick
        threading.Timer(2, self.run_dog).start()


def sendustplayer_udp_send(host, port):
    global caspar_info
    text_send = ""
    try:
        text_send = ("time0**" + str(caspar_info.time0)
                    + "\ntime1**" + str(caspar_info.time1)
                    + "\nclip0**" + str(caspar_info.clip0)
                    + "\nclip1**" + str(caspar_info.clip1)
                    + "\nname_foreground**" + str(caspar_info.name_foreground)
                    + "\nname_background**" + str(caspar_info.name_background)
                    + "\npath_foreground**" + str(caspar_info.path_foreground)
                    + "\nposition_run**" + str(caspar_info.position_run)
                    + "\nproducer_foreground**" + str(caspar_info.producer_foreground)
                    + "\nsmpte_dur**" + str(caspar_info.smpte_dur)
                    + "\nsmpte_rem**" + str(caspar_info.smpte_rem)
                    + "\nsmpte_run**" + str(caspar_info.smpte_run)
                    + "\ntime_rem**" + str(caspar_info.time_rem)
                    + "\ntime_run**" + str(caspar_info.time_run)
                    + "\ntime_tick**" + str(caspar_info.time_tick)
                    + "\nloop**" + str(caspar_info.loop)
                    + "\npaused**" + str(caspar_info.paused))
    
    except Exception as e:
        updatelog("Raise exception while creating udp text" + str(e))
    
    
    
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.sendto(bytes(text_send, "utf-8"), (host, port))
    threading.Timer(0.2,sendustplayer_udp_send, [host, port]).start()


def character_udp_send(host, port):
    global caspar_info
    text_send = str(caspar_info.smpte_run)
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as s:
        s.sendto(bytes(text_send, "utf-8"), (host, port))
    threading.Timer(0.067,character_udp_send, [host, port]).start()


class Chk_single_instance:
    f = ""
    def __init__(self):
        print("Creating Single instance checker class....")
        try:
            self.f = open("pid_casparinfo.txt", "w")
            self.f.writelines(str(os.getpid()))
            portalocker.lock(self.f, portalocker.LOCK_EX)     # lock file for exclusive access
        except Exception as e:                                   # exit to system if file is locked
            print(str(e))
            sys.exit()

    def __del__(self):
        print("Deleting Single instance checker class....")
        try:
            self.f.close()
        except Exception as e:
            print(str(e))



updatelog("Application start -----------------------------------------")
updatelog("PID is " + str(os.getpid()))
ctypes.windll.kernel32.SetConsoleTitleW("Caspar info reader by sendust")          ## Change console title

chk_instance = Chk_single_instance()                # Check if same script running already
caspar_info = Caspar_info()

amcp = Amcp("127.0.0.1", 5250) 
amcp.sendinfo(1)

sendustplayer_udp_send("127.0.0.1", 34410)          # caspar info send data port
character_udp_send("127.0.0.1", 40000)              # Timecode data for HTML TC Display

time.sleep(5)        # Run Watch dog with delay

watch_dog = Watch_dog()                        # run watch dog
watch_dog.run_dog()
