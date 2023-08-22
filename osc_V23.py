#  Caspar OSC Reader by sendust 2021/3/11
#  Display Audio level meter with pygame
#  reports playback head position in second
#  report useful information
#  Require CasparCG version 2.3 or higher
#   2021/3/19    Improve image producer handling (osc does not report name_foreground)
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
import math


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

def sec_to_smpte(second):
    frames = second * 29.97
    return frames_to_timecode(frames)
    

def print_handler(address, *args):
    print(f"{address} : {args}")

    if address == "/channel/1/mixer/audio/volume":
        levelmeter.volume = args
        print("Found Level meter data ###################")
        print(args)
        #levelmeter.value[0] = 1.4 ** (math.log( (args[0] + 0.01) / 2147483648, 10) * 3) * 100
        for i in range(0, 8):
            levelmeter.value[i] = 1.4 ** (math.log( (args[i] + 0.01) / 2147483648, 10) * 3) * 100   # Make favorite Level meter response
        print(levelmeter.value)         # Confirm calculated value
                    
            
    if address == "/channel/1/stage/layer/1/foreground/file/clip":
        info_display.clip = args
    if address == "/channel/1/stage/layer/1/foreground/file/name":
        info_display.name_foreground = args
        info_display.tick["name_foreground"] = time.perf_counter()
        
    if address == "/channel/1/stage/layer/1/foreground/file/path":
        info_display.path_foreground = args
        info_display.tick["path_foreground"] = time.perf_counter()
    if address == "/channel/1/stage/layer/1/foreground/file/time":
        info_display.time = args
    if address == "/channel/1/stage/layer/1/foreground/loop":
        info_display.loop = args
    if address == "/channel/1/stage/layer/1/foreground/paused":
        info_display.paused = args
    if address == "/channel/1/stage/layer/1/foreground/producer":
        info_display.producer = args
    if address == "/channel/1/stage/layer/1/background/file/name":
        info_display.name_background = args
        info_display.tick["name_background"] = time.perf_counter()


    if (time.perf_counter() - info_display.tick["name_foreground"]) > 0.2:      # no osc message -> set to default value
        info_display.name_foreground = [""]
        info_display.set_default_time()

    if (time.perf_counter() - info_display.tick["path_foreground"]) > 0.2:      # no osc message -> set to default value
        info_display.path_foreground = [""]

    if (time.perf_counter() - info_display.tick["name_background"]) > 0.2:
        info_display.name_background = [""]
        
    osc_to_caspar_info()
#
# clip0 ; mark in position in second
# clip1 ; duration in second (mark out - mark in)
# time0 ; absolute playback head position in second
# time1 ; entire file duration in second
#
#


    
def osc_to_caspar_info():
    caspar_info.clip0 = float(info_display.clip[0])
    caspar_info.clip1 = float(info_display.clip[1])
    caspar_info.time0 = float(info_display.time[0])
    caspar_info.time1 = float(info_display.time[1])
    
    if len(info_display.name_foreground[0]):
        caspar_info.name_foreground = "/" + info_display.name_foreground[0]
        caspar_info.name_foreground = caspar_info.name_foreground.replace("//", "/")
        caspar_info.path_foreground = caspar_info.media_path + caspar_info.name_foreground
        caspar_info.path_foreground = caspar_info.path_foreground.replace("/", "\\")
    else:        
        caspar_info.name_foreground = ""
        caspar_info.path_foreground = ""
    
   
    caspar_info.producer_foreground = info_display.producer[0]
    caspar_info.time_run = float(info_display.time[0]) - float(info_display.clip[0])
    caspar_info.time_rem = float(info_display.clip[0]) + float(info_display.clip[1]) - float(info_display.time[0])
    caspar_info.time_tick = time.perf_counter()
    caspar_info.loop = info_display.loop[0]
    caspar_info.paused = info_display.paused[0]
    
    if caspar_info.producer_foreground == "image":
        caspar_info.name_foreground = info_display.path_foreground[0].replace(caspar_info.media_path, "")
        caspar_info.name_foreground = caspar_info.name_foreground.replace("\\", "")
        caspar_info.path_foreground = caspar_info.media_path + caspar_info.name_foreground
        caspar_info.path_foreground = caspar_info.path_foreground.replace("/", "\\")
        caspar_info.name_foreground = caspar_info.name_foreground.replace("//", "/")
        
        

    if len(info_display.name_background[0]):
        caspar_info.name_background = "/" + info_display.name_background[0]
    else:
        caspar_info.name_background = ""
    
    if caspar_info.clip1:
        caspar_info.position_run = caspar_info.time_run / caspar_info.clip1
    else:
        caspar_info.position_run = 0
    caspar_info.producer_foreground = info_display.producer[0]

    caspar_info.smpte_dur = frames_to_timecode(float(info_display.clip[1]) * 29.97)
    caspar_info.smpte_rem = frames_to_timecode(caspar_info.time_rem * 29.97)
    caspar_info.smpte_run = frames_to_timecode(caspar_info.time_run * 29.97)
    


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

    text = font.render(sec_to_smpte(caspar_info.time0) + " / " + sec_to_smpte(caspar_info.time1) , True, (255, 255, 255))
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
        print("Media path is " + self.media_path)

class LEVELMETER_develop:
    value = [0, 0, 0, 0, 0, 0, 0, 0]    # initial each volume value
    position = [(10, 100), (40, 100), (70, 100), (100, 100), (130, 100), (160, 100), (190, 100), (220, 100)]
    width = 26
    color = (255, 255, 0)
    
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
                "clip0" : (10,170), "clip1" : (10, 200),
                "name_background" : (10, 230),
                "path_foreground" : (10, 370),
                "paused" : (10, 400), 
                "loop" : (10, 430), 
                "producer" : (10, 460) }
                
                
    def set_default(self):
        self.time = [0, 86400]         # initial value before osc reception
        self.clip = [0, 86400]
        self.path_foreground = [""]
        self.name_foreground = [""]
        self.name_foreground = [""]
        self.name_background = [""]
        self.paused = ["----"]
        self.loop = ["----"]
        self.producer = ["----"]
        self.time_tick = time.perf_counter()
        self.tick = {}
        self.tick["name_foreground"] = time.perf_counter()
        self.tick["name_background"] = time.perf_counter()
        self.tick["path_foreground"] = time.perf_counter()
     
    def set_default_time(self):
        self.time = [0, 86400]         # initial value before osc reception
        self.clip = [0, 86400]
     

class OSCLISTEN:    # New v23

    def __init__(self, ip, port):
        self.ip = ip
        self.port = port
        updatelog("Creating osc listen object")
    
    def set_filter(self):
        self.dispatcher = Dispatcher()
        self.dispatcher.map("/channel/1/mixer/audio/volume", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/foreground/file/*", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/background/file/name", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/foreground/loop", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/foreground/paused", print_handler)
        self.dispatcher.map("/channel/1/stage/layer/1/foreground/producer", print_handler)
       
    def run_server(self):
        self.server = BlockingOSCUDPServer((self.ip, self.port), self.dispatcher)
        self.server.serve_forever()

        
        
class GAMEWINDOW():
    def __init__(self, size_x, size_y):
        updatelog("Creating pygame window object")
        os.environ['SDL_VIDEO_WINDOW_POS'] = "%d,%d" % (1000, 20)   # Set Start up window position 
        pygame.init()
        self.title = "Caspar v2.2 OSC Monitor by sendust"
        pygame.display.set_caption(self.title)
        self.screen = pygame.display.set_mode((size_x, size_y))
        #self.backimage = pygame.image.load('vfd_osc.png')  # for Develop
        #self.backimage = pygame.image.load('vfd_osc_1.png')
    def display(self):
        clock = pygame.time.Clock()
        done = False
        while not done:
            print("pygame loop is running //////////////////////")
            if pygame.event.poll().type == pygame.QUIT:
                done = True

            self.screen.fill((23,23,23))
            #self.screen.blit(self.backimage, (0, 0))        # Draw background widh image
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

#window = GAMEWINDOW(640, 480)      # Develop
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

