* Create a state machine that holds config and timer
* If command is received and state machine is not found - create a new one with state=Stopped and apply the command
* Handle Start -> transition to state=Started and run a timer
* Handle Pause -> go to state=Stopped
* Handle Reset -> reset timer and leave the state in place
* Handle Stop -> reset and go to the state=Stopped
* Remove state machines that are not used for more than 12 hours
