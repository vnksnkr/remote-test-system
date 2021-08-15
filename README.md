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

There is a driver available to upload the generated bitstream to the  routing fabrics' (MachXO2) SRAM :

[https://github.com/Swaraj1998/axiom-beta-rfdev]()

Remove the module before proceeding with the tests:

```
rmmod rfdev
```

### Using the test framework:

#### class remote

remote implements the testing framework for the AXIOM Remote. At the lower level it uses a JTAG Interface to use the internal JTAG access on the MachXO2 for communication.

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

  loads a seed value for generating random pulses to simulate button bounces and encoder skips
* ```
  remote.bounce_off()
  ```

  turns off the bouncing
* ```
  remote.select(address)
  ```

  sets the default address of the component to be used to 'address'
* ```
  remote.press(address,duration)
  ```

  presses the button corresponding to the address passed. Default address is taken if no value passed.
  The argument duration specifies the time interval between the button press and release.
* ```
  remote.turn(address=None,duration,ticks,counter=False)
  ```

  turns the knob corresponding to the address passed. Default address is taken if no value passed.
  The argument duration specifies the time interval of the each pulse sent from the encoder
  The argument ticks specifies the number of turns the encoder makes
  The argument counter, when set to True, turns the encoder in the counter-clockwise direction
* ```
  remote.wait()
  ```

  waits for the previous instruction to be decoded by the gateware. remote.wait() should always follow remote.press() or remote.turn() while writing automated scripts
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

  resets the JTAG communication between the 	AXIOM Beta and the remote

---

```

```
