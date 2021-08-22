#!/bin/env python3

# Copyright (C) 2021 Vinayak Sankar


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
    E1 = "10010"
    E2 = "10000"

    POLL_CMD = "10001"
    RESET_CMD = "10100"
    SEED_CMD = "10011"
    PARAM_CMD = "10101"
    RCV_CMD = "10"*19
    JTAGOFF_CMD = "1"*38

    def __init__(self, bus):
        self.i2c = SMBus(bus)
        self.jtag = JTag(self.i2c)
        self.def_addr = "00000"

    def generate_seed(self):
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
        self.wait()
        self.jtag.off()

    def bounce_off(self):
        seed_s = '0'*13
        cmd = '0'*20 + seed_s + self.SEED_CMD
        status = self.jtag.cmdshift(h2b("32"),cmd)
        return status


    def loadseed(self, seed=None):
        if seed == None:
            seed_s = self.generate_seed()
        else:
            seed_s = h2b(seed).zfill(13)
        cmd = '0'*20+ seed_s + self.SEED_CMD
        status = self.jtag.cmdshift(h2b("32"),cmd)
        return(status)


    def freq_div(self, duration):
        div = bin(int(round((duration/1000)*2560000)))[2:].zfill(22)
        return div

    def select(self, address):
        self.def_addr = address

    def remove_selection(self):
        self.def_addr = "11111"

    def reset(self):
        cmd = '0'*33 + self.RESET_CMD
        self.jtag.cmdin(h2b("32"), cmd)
        return 1

    def press(self, address=None, duration=15):
        if address == None:
            address = self.def_addr
        if address == self.E1 or address == self.E2:
            print("Selected component is not button")
            return 0

        press_count = bin(1)[2:].zfill(6)
        cmd = press_count + self.freq_div(duration) + address + self.PARAM_CMD
        status = self.jtag.cmdshift(h2b("32"),cmd)
        return 1


    def turn(self, address=None, duration=15, ticks=1, counter=False):
        if address == None:
            address = self.def_addr

        if address != self.E1 and address != self.E2:
            print("Selected component is not encoder")
            return 0

        ticks_s = bin(ticks)[2:].zfill(6)
        if counter == True:
            address = address[:-1] + "1"

        print("turning encoder ", address)
        cmd = ticks_s + self.freq_div(duration) + address + self.PARAM_CMD
        status = self.jtag.cmdshift(h2b("32"),cmd)
        return 1

    def poll(self,resp=True):
        cmdrcv = self.jtag.cmdshift(h2b("32"),'0'*33 + self.POLL_CMD)
        if resp == True:
            if cmdrcv == self.RCV_CMD:
                print("No ongoing operation, no instruction in queue")
            elif cmdrcv == self.JTAGOFF_CMD:
                print("JTAG OFF")
            else:
                print("Busy, instruction in queue")
        return cmdrcv


    def wait(self,resp=False):
        cmdrcv = self.poll(resp)
        while cmdrcv != self.RCV_CMD and cmdrcv != self.JTAGOFF_CMD:
            cmdrcv = self.poll(resp)
        return 1

