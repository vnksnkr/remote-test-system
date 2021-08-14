To allow for testing the AXIOM Remote, in an automated way, an interface (AXIOM Beta shield and Add-On PCB) was designed which allows to press buttons and turn dials on the AXIOM Remote from the AXIOM Beta. The shield is connected to one of the routing fabric FPGAs.This repository contains the gateware developed to interface the shield with the Remote and a test framework to run automated tests.

## Features :

* Automated testing and Real-time Control Support
* Advanced actions for testing such as bounces, encoder skipping
* Easy to use python framework

## Usage :

### Building the gateware:


### Uploading the bitstream:

* There is a driver available to upload the generated bitstream to the  routing fabrics' (MachXO2) SRAM :

[   https://github.com/Swaraj1998/axiom-beta-rfdev]()

* Remove the module before proceeding with the tests:

<code> rmmod rfdev

### Using the test framework:
