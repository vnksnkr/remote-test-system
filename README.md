# Remote Test System for AXIOM Remote

To allow for testing the AXIOM Remote, in an automated way, an interface (AXIOM Beta shield and Add-On PCB) was designed which allows to press buttons and turn dials on the AXIOM Remote from the AXIOM Beta. The shield is connected to one of the routing fabric FPGAs.This repository contains the gateware developed to interface the shield with the Remote and a test framework to run automated tests.

## Features :

* Automated testing and Real-time Control Support
* Advanced actions for testing such as button bounces, encoder skipping
* Easy to use python framework

## Usage :

### Building the gateware:

Lattice Diamond needs to be installed for building the gateware. Run the following commands as root.

```
git clone https://github.com/vnksnkr/remote-test-system.git
```

```
cd remote-test-system
```

Make sure the version of Lattice Diamond specifed in Makefile is the version found in the system

```
make
```

The generated bitstream can be found in build/ directory

### Uploading the bitstream:

There is a driver available to upload the generated bitstream to the  routing fabrics' (MachXO2) SRAM . To upload via the driver follow the instructions at :
https://github.com/vnksnkr/axiom-beta-rfdev

After uploading the bitstream, remove the module before proceeding with the tests as JTAG is needed for communication:

```
rmmod rfdev
```

### Using the test framework:

The framework can be used to run automated scripts for testing purposes . An example is provided at the bottom.

It can also be used to control the remote in real time from the Axiom Beta by running it in interactive mode :

```
python -i remote_remote.py
```

#### class remote

**remote** implements the testing framework for the AXIOM Remote. At the lower level it uses a JTAG Interface to use the internal JTAG access on the MachXO2 for communication.

remote objects can be initialized using :

```
from remote_remote import *
testremote = remote(2) 

```

2 being the i2c address

#### Methods :

* ```
  remote.on()
  ```

  sets up communication between the gateware that controls the remote, and the AXIOM Beta
* ```
  remote.loadseed(seed=None)
  ```

  loads a **seed** value for generating random pulses to simulate button bounces and encoder skips
  loads a randomly generated seed if no value passed as argument
* ```
  remote.bounce_off()
  ```

  turns off the bouncing
* ```
  remote.select(address)
  ```

  sets the default address of the component to be used, to argument **address**
* ```
  remote.press(address,duration)
  ```

  presses the button corresponding to the address passed. Default address is taken if no value passed.
  The argument **duration**(unit = ms) specifies the time interval between the button press and release.
* ```
  remote.turn(address=None,duration,ticks,counter=False)
  ```

  turns the knob corresponding to the address passed. Default address is taken if no value passed.
  The argument **duration**(unit = ms) specifies the time interval of the each pulse sent from the encoder
  The argument **ticks** specifies the number of turns the encoder makes
  The argument **counter**, when set to True, turns the encoder in the counter-clockwise direction
* ```
  remote.poll()
  ```

  returns the current state of the gateware ( i.e busy or idle)
* ```
  remote.wait()
  ```

  waits for the previous instruction to be decoded by the gateware.

  > NOTE : remote.wait() should  follow remote.press() or remote.turn() while writing automated scripts
  >
* ```
  remote.remove_selection()
  ```

  clears the default address of the component
* ```
  remote.reset()
  ```

  resets the internal state of the gateware
* ```
  remote.reset_jtag()
  ```

  resets the JTAG communication between the 	AXIOM Beta and the Remote

#### Addresses:

The following addresses can be passed as arguments for the Axiom Remote :

1. Push Buttons : P1 - P13
2. Encoder : E1,E2
3. Encoder Buttons : E1_S,E2_S

#### Example Usage:

```
from remote_remote import *

testremote = remote(2)
testremote.on() 						#initiates JTAG connection
testremote.bounce_off()						#turns off bouncing
testremote.wait()					 
testremote.press(address=testremote.P13,duration=10) 		#presses Push Button P13 for 10ms
testremote.wait() 						#waits for acknowledge
testremote.press(address=testremote.E1_S,duration=10) 		#presses Encoder 1 Button for 10ms
testremote.wait()
testremote.turn(address=testremote.E2,ticks=2,duration=15) 	#turns Encoder 2, 2 ticks, each tick having pulse of duration 15ms
testremote.wait()
testremote.loadseed()						#loads seed value(generated randomly) to switch on bouncing  
testremote.wait()
testremote.press(address=testremote.P2,duration=10)
testremote.wait()
testremote.reset() 						#resets the internal logic of the gateware
testremote.off() 						#closes JTAG connection
```
