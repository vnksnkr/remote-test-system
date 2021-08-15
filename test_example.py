from remote_remote import *

testremote = remote(2)
testremote.on() 						                    #initiates JTAG connection
testremote.bounce_off()						                #turns off bouncing 
testremote.press(address=testremote.P13,duration=10) 		#presses Push Button P13 for 10ms
testremote.wait() 						                    #waits for acknowledge
testremote.press(address=testremote.E1_S,duration=10) 		#presses Encoder 1 Button for 10ms
testremote.wait()
testremote.turn(address=testremote.E2,ticks=2,duration=15) 	#turns Encoder 2, 2 ticks, each tick having pulse of duration 15ms
testremote.wait()
testremote.loadseed()						                #loads seed value(generated randomly) to switch on bouncing  
testremote.press(address=testremote.P2,duration=10)
testremote.wait()
testremote.reset() 						                    #resets the internal logic of the gateware
testremote.off() 						                    #closes JTAG connection
