#  Caspar OSC Reader by sendust 2021/3/11
#  Display Audio level meter with pygame
#  reports playback head frame number, markers, 
#  report useful information
#  Require CasparCG version 2.1 or less
# 
#  2021/3/25    Improve image producer 
#
#
#
#

from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import BlockingOSCUDPServer
from datetime import datetime
import threading
import pygame
import ctypes
import time
import os
import sys
import socket
import traceback
import configparser
import portalocker              # manual installation requested
import logging
import win32gui


#sys.stderr = open("nul", "w")

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
    if frames < 0:
        sign = "-"
        frames = frames * (-1)
    else:
        sign = ""
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
    return sign + result.format(h = hours, m = minutes, s = seconds, f = frame)
    

def print_handler(address, *args):
    print(f"{address} : {args}")

    #if address == "/channel/1/mixer/audio/1/dBFS":
    #    print("Found Mixer audio channel 1 level !!!!!!!!!!!!!!!!!!")
    #    levelmeter.value[0] = 1.5 ** (args[0] / 10 + 10) + 1  # Make favorite Level meter response
    #    print(levelmeter.value[0])              # silence level = -192.65921020507812
    if address[0:23] == "/channel/1/mixer/audio/":
        if address[25:29] == "dBFS":
            levelmeter.value[int(address[23]) - 1] = 1.5 ** (args[0] / 10 + 10) + 1  # Make favorite Level meter response
            
    if address == "/channel/1/stage/layer/1/file/markers":
        info_display.markers = args
    if address == "/channel/1/stage/layer/1/file/clip":
        info_display.clip = args
    if address == "/channel/1/stage/layer/1/file/time":
        info_display.time = args
    if address == "/channel/1/stage/layer/1/file/path":
        info_display.path = args
    if address == "/channel/1/stage/layer/1/profiler/time":
        info_display.time_profiler = args
    if address == "/channel/1/stage/layer/1/paused":
        info_display.time_tick = time.perf_counter()
        info_display.paused = args
    if address == "/channel/1/stage/layer/1/loop":
        info_display.loop = args
    if address == "/channel/1/stage/layer/1/producer/type":
        info_display.type = args

    if (time.perf_counter() - info_display.time_tick) > 0.2:  # play, pause state report 'pause' flag, clear channel does not report 'pause' flag
        info_display.set_default()                            # Decide if clip is loaded or not
                                                              # Pause state does not report  /layer/1/file/path
        
    osc_to_caspar_info()


def osc_to_caspar_info():
    caspar_info.clip0 = float(info_display.markers[0]) / 29.97
    caspar_info.clip1 = (float(info_display.markers[1]) -  float(info_display.markers[0]) ) / 29.97
    caspar_info.time0 = float(info_display.time[0])
    caspar_info.time1 = float(info_display.time[1])
    
    if len(info_display.path[0]):
        if info_display.type[0] != "image":
            caspar_info.name_foreground = "/" + info_display.path[0]
            caspar_info.path_foreground = caspar_info.media_path + "/" + info_display.path[0]
            caspar_info.path_foreground = caspar_info.path_foreground.replace("/" , "\\")
    else:
        caspar_info.name_foreground = ""
        caspar_info.path_foreground = ""
    
    if info_display.type[0] == "image":
        #updatelog("type is image, path is " + info_display.path[0])
        caspar_info.name_foreground = info_display.path[0].replace(caspar_info.media_path.replace("\\", "/"), "")
        caspar_info.name_foreground = caspar_info.name_foreground.replace("//", "/")
        caspar_info.path_foreground = info_display.path[0].replace("//", "/")
        caspar_info.path_foreground = caspar_info.path_foreground.replace("/", "\\")
        updatelog("modified path is " + caspar_info.path_foreground)
    
    caspar_info.producer_foreground = info_display.type[0]
    caspar_info.time_run = (float(info_display.clip[2]) - float(info_display.markers[0])) / 29.97
    caspar_info.time_rem = (float(info_display.markers[1]) - float(info_display.clip[2])) / 29.97
    caspar_info.time_tick = time.perf_counter()
    caspar_info.loop = info_display.loop[0]
    caspar_info.paused = info_display.paused[0]
    
    caspar_info.name_background = ""
    caspar_info.position_run = caspar_info.time_run / caspar_info.clip1
    caspar_info.producer_foreground = info_display.type[0]


    caspar_info.smpte_dur = frames_to_timecode(float(info_display.markers[1]) -  float(info_display.markers[0]))
    caspar_info.smpte_rem = frames_to_timecode(float(info_display.markers[1]) - float(info_display.clip[2]))
    caspar_info.smpte_run = frames_to_timecode(float(info_display.clip[2]) - float(info_display.markers[0]))
    


def drawframe():
    font = pygame.font.Font("DSEG7Classic-Italic.ttf", 15)
    
    for i in range(0, 8):
        x = levelmeter.position[i][0]
        y = levelmeter.position[i][1]
        pygame.draw.line(window.screen, levelmeter.color , (x, y), (x, y - int(levelmeter.value[i])), levelmeter.width)
        text = font.render( str(i + 1), True, (255, 255, 255))
        window.screen.blit(text, levelmeter.position_ch[i])

        
    font = pygame.font.Font("monofonto.ttf", 20)
    
    text = font.render(caspar_info.smpte_run + " / " + caspar_info.smpte_dur , True, (255, 255, 255))
    window.screen.blit(text, (290,50))

    text = font.render(frames_to_timecode(float(info_display.clip[2])) + " / " + frames_to_timecode(float(info_display.clip[3])) , True, (255, 255, 255))
    window.screen.blit(text, (290,80))

    font = pygame.font.Font("naverdic.ttf", 17)
    
    text = font.render(caspar_info.name_foreground , True, (255, 255, 255))
    window.screen.blit(text, (20,130))

    pygame.display.flip() 


def list_system_font():
    for i in pygame.font.get_fonts():
        print(i)



def sendustplayer_udp_send(host, port):
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



class Caspar_info:

    def __init__(self):
        updatelog("Creating Caspar info object")
        max_duration = 86400
        self.max_duration = max_duration
        self.time_run_old = 0
        self.time_run = 0
        self.time_rem = 86400
        self.time_tick = 0
        self.position_run = 0
        
        self.clip0 = 0
        self.clip1 = max_duration
        self.time0 = 0
        self.time1 = max_duration

        self.name_foreground = ""
        self.name_background = ""
        self.path_foreground = ""
        self.position_run = 0
        self.producer_foreground = ""

        self.smpte_dur = ""
        self.smpte_rem = ""
        self.smpte_run = ""
        
        self.paused = ""
        self.loop = ""

        try:
            casparconfig = readini("sendust_player1.ini")
            self.media_path = casparconfig["caspar"]["caspar_mediapath"]
        except:
            self.media_path = "d:\\capture"



class LEVELMETER:
    value = [0, 0, 0, 0, 0, 0, 0, 0]    # initial each volume value
    position_start = 30
    position_end = 250
    distance = ( position_end - position_start ) / 7
    position = []
    position_ch = []
    for i in range(0, 8):
        position.append((position_start + i * distance, 100))
        position_ch.append((position_start + i * distance - 5, 105))
    width = 20
    color = (255, 255, 0)
    

class INFO_DISPLAY:
    def __init__(self):
        updatelog("Creating info display object")
        self.position = {"time0" : (10, 110), "time1" : (10, 140), 
                "clip0" : (10,170), "clip1" : (10, 200), "clip2" : (10,230), "clip3" : (10,260),
                "markers0" : (10, 300), "markers1" : (10, 330), 
                "path" : (10, 370),
                "paused" : (10, 400), 
                "loop" : (10, 430), 
                "type" : (10, 460) }
                
    def set_default(self):
        self.time = [0, 0]         # initial value before osc reception
        self.clip = [0, 0, 0, 2589408]
        self.markers = [0, 2589408]
        self.path = [""]
        self.time_profiler = [-1, -1]
        self.paused = ["----"]
        self.loop = ["----"]
        self.type = ["----"]
        self.time_tick = time.perf_counter()
    
    #   time0 ; absolute playback head position (unit is second)
    #   time1 ; total file duration (do not consider mark in, out) (unit is second)
    #   clip0 ;
    #   clip1
    #   clip2 ; absolute playback head position (unit is frame)
    #   clip3 ; total file duration (do not consider mark in, out) (unit is frame)
    #   markers0 ; mark in position (unit is frame)
    #   markers1 ; mark out position  (unit is frame)
    #   path ;   foreground loaded clip name sbscm.mxf   ts-3/test.mov  (OSC does not report path when paused !!!)
    #   time_profiler ; frame time (unit in second)
    #   


class OSCLISTEN:

    def __init__(self, ip, port):
        self.ip = ip
        self.port = port
        updatelog("Creating osc listen object")
    
    def set_filter(self):
        self.dispatcher = Dispatcher()
        self.dispatcher.map("/channel/1/stage/layer/1/file/markers", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/file/clip", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/file/time", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/profiler/time", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/file/path", print_handler)
        self.dispatcher.map("/channel/1/mixer/audio/*/dBFS", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/paused", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/loop", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/producer/type", print_handler)
       
    def run_server(self):
        self.server = BlockingOSCUDPServer((self.ip, self.port), self.dispatcher)
        self.server.serve_forever()


class GAMEWINDOW():
    def __init__(self, size_x, size_y):
        updatelog("Creating pygame window object")
        os.environ['SDL_VIDEO_WINDOW_POS'] = "%d,%d" % (1000, 20)   # Set Start up window position 
        pygame.init()
        self.title = "Caspar v2.1 OSC Monitor by sendust"
        pygame.display.set_caption(self.title)
        self.screen = pygame.display.set_mode((size_x, size_y))
        #self.backimage = pygame.image.load('vfd_osc.png')
    def display(self):
        clock = pygame.time.Clock()
        done = False
        while not done:
            print("pygame loop is running //////////////////////")
            if pygame.event.poll().type == pygame.QUIT:
                done = True

            self.screen.fill((23,23,23))
            #self.screen.blit(self.backimage, (0, 0))
            drawframe()
            #pygame.display.flip()
            clock.tick(60)
        pygame.quit()

    def bring_front(self):
        #hwnd = win32gui.FindWindowEx(0,0,0, self.title)
        hwnd = win32gui.FindWindow(None, self.title)  
        print("Activate Levelmetger window ------------------")
        print(hwnd)
        win32gui.ShowWindow(hwnd, 9)        # Restore Levelmeter if window is minimized

updatelog("Application start -----------------------------------------")
updatelog("PID is " + str(os.getpid()))
ctypes.windll.kernel32.SetConsoleTitleW("Caspar info reader by sendust")          ## Change console title

chk_instance = Chk_single_instance()                # Check if same script running already
caspar_info = Caspar_info()


#list_system_font()

#window = GAMEWINDOW(640, 480)
window = GAMEWINDOW(550, 160)

osc = OSCLISTEN("127.0.0.1", 5253)
osc.set_filter()

levelmeter = LEVELMETER
info_display = INFO_DISPLAY()
info_display.set_default()          # setup initial value

threading.Thread(target = osc.run_server, daemon=True).start()           # Start OSC listen thread
sendustplayer_udp_send("127.0.0.1", 34410)          # caspar info send data port
character_udp_send("127.0.0.1", 40000)              # Timecode data for HTML TC Display
threading.Timer(1, window.bring_front).start()

window.display()

