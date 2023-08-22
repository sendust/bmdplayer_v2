from pythonosc.dispatcher import Dispatcher
from pythonosc.osc_server import BlockingOSCUDPServer
import threading
import pygame



def print_handler(address, *args):
    print(f"{address} : {args}")
    
    

class OSCLISTEN:
    
    def __init__(self, ip, port):
        self.ip = ip
        self.port = port
    
    def set_filter(self):
        self.dispatcher = Dispatcher()
        self.dispatcher.map("/*", print_handler)

       
    def run_server(self):
        self.server = BlockingOSCUDPServer((self.ip, self.port), self.dispatcher)
        self.server.serve_forever()

osc = OSCLISTEN("127.0.0.1", 5253)
osc.set_filter()
osc.run_server()
