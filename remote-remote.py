import sys

from smbus import SMBus
from bitarray import bitarray
from axiom_jtag import *
from axiom_mxo2 import *

class remote:
    P1 = "00000"
    P2 = "00001"
    P3 = "00010"
    P4 = "00011"
    P5 = "00100"
    P6 = "00101"
    P7 = "00110"
    P8 = "00111"
    P9 = "01000"
    P10 = "01001"
    P11 = "01010"
    P12 = "01011"
    P13 = "01100"
    E1_S  = "01101"
    E2_S =  "01110"
    E1 =    "10000"
    E2 = "10010"

    JTAG_CMD = "1000001"
    RESET_CMD = "10000011"
    SEED_CMD = "10000001"
    PARAM_CMD = "10000101"


    rand_seed = ""
  
    def __init__(self,bus):
        self.i2c = SMBus(bus)
        self.jtag = JTag(self.i2c)
        self.def_addr = "00000"

    def on(self):
        self.jtag.on()
        self.jtag.reset()

    def reset(self):
        self.jtag.reset()
    
    def off(self):
        self.jtag.off()

    def bounce_off(self):
        seed_s = '0'*13
        cmd = self.JTAG_CMD +'0'*20+ seed_s +self.SEED_CMD
        self.jtag.cmdin("32",cmd)

    def loadseed(self,seed=rand_seed):
        seed_s = h2b(seed).zfill(13)
        cmd = self.JTAG_CMD +'0'*20+ seed_s +self.SEED_CMD
        self.jtag.cmdin("32",cmd)

    def freq_div(duration):
        div = ""
        return div

    def select(self,address):
        self.def_addr = address

    def press(self,address=None,duration=0):
        if address == None:
            address = self.def_addr
        if address == self.E1 or address == self.E2:
            print("Selected component is not button")
            return  0
        press_count = h2b("1")[2:]
        cmd = self.JTAG_CMD + press_count + self.freq_div(duration) + address + self.PARAM_CMD
        self.jtag.cmdin("32",cmd)
        return 1


    def turn(self,address=None,duration=0,ticks=0,counter=False):
        if address == None:
            address = self.def_addr

        if address != self.E1 and address != self.E2:
            print("Selected component is not encoder")
            return  0

        ticks_s = h2b(ticks)[3:]
        if counter == True:
            address[5] = address[:-1] + '1'
        cmd = self.JTAG_CMD + ticks_s + self.freq_div(duration) + address + self.PARAM_CMD
        return 1
    

