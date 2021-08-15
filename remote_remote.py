import sys

from smbus import SMBus
from bitarray import bitarray
from axiom_jtag import *
from axiom_mxo2 import *
import random


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
    E1_S = "01101"
    E2_S = "01110"
    E1 = "10000"
    E2 = "10010"

    JTAG_CMD = "1000001"
    RESET_CMD = "10000011"
    SEED_CMD = "10000001"
    PARAM_CMD = "10000101"
    RCV_CMD = "100"*16

    def __init__(self, bus):
        self.i2c = SMBus(bus)
        self.jtag = JTag(self.i2c)
        self.def_addr = "00000"

    def generate_seed():
        rand_seed = random.randrange(1, 8192)
        return bin(rand_seed)[2:].zfill(13)

    def on(self):
        self.jtag.on()
        self.jtag.reset()
        self.jtag.sir(h2b("32"))
        self.jtag.idle()

    def reset_jtag(self):
        self.jtag.reset()

    def off(self):
        self.reset()
        self.jtag.off()

    def bounce_off(self):
        seed_s = '0'*13
        cmd = self.JTAG_CMD + '0'*20 + seed_s + self.SEED_CMD
        self.jtag.cmdin(h2b("32"), cmd)

    def loadseed(self, seed=None):
        if seed == None:
            seed_s = self.generate_seed()
        else:
            seed_s = h2b(seed).zfill(13)
        cmd = self.JTAG_CMD + '0'*20 + seed_s + self.SEED_CMD
        self.jtag.cmdin(h2b("32"), cmd)

    def freq_div(self, duration):
        div = bin(int(round((duration/1000)*2560000)))[2:].zfill(22)
        print(div)
        return div

    def select(self, address):
        self.def_addr = address

    def remove_selection(self):
        self.def_addr = "11111"

    def reset(self):
        cmd = self.JTAG_CMD + '0'*33 + self.RESET_CMD
        self.jtag.cmdin(h2b("32"),cmd)
        return 1

    def press(self, address=None, duration=15):
        if address == None:
            address = self.def_addr
        if address == self.E1 or address == self.E2:
            print("Selected component is not button")
            return 0

        press_count = bin(1)[2:].zfill(6)
        cmd = self.JTAG_CMD + press_count + self.freq_div(duration) + address + self.PARAM_CMD
        self.jtag.cmdin(h2b("32"), cmd)
        return 1

    def turn(self, address=None, duration=15, ticks=1, counter=False):
        if address == None:
            address = self.def_addr

        if address != self.E1 and address != self.E2:
            print("Selected component is not encoder")
            return 0

        ticks_s = bin(ticks)[2:].zfill(6)
        if counter == True:
            address = address[:-1] + '1'
        cmd = self.JTAG_CMD + ticks_s + self.freq_div(duration) + address + self.PARAM_CMD
        self.jtag.cmdin(h2b("32"), cmd)
        return 1


    def wait(self):
        cmdrcv = self.jtag.cmdout(h2b("32"), 48)
        while cmdrcv == self.RCV_CMD:
            cmdrcv = self.jtag.cmdout(h2b("32"), 48)
        return 1


