clearscreen.
print "Counting down:".
from {local countdown is 5.} until countdown = 0 step {set countdown to countdown - 1.} do {
    print "T-" + countdown.
    wait 1.
}

print "Lift-of!".

lock steering to up.
// i use solidboosters... no need for throttle (Ilwasik).
lock throttle to 1.0.

set x to 0.

//stage twice with a when loop
when maxthrust = 0 and x < 2 then {
    
    set x to x + 1.
    print "Staging".
    stage.
    
    preserve. //keeps checking for this condition
}

wait until x = 2.

when maxthrust = 0 and x > 2 then {
    wait 5.
    print "Probe separation".
    stage.
    lock throttle to 0.0.
}

unlock throttle.

//wait unil we are at 70000 and have an orbit
wait until ship:altitude > 70000 and ship:orbit = true.

//check if we indeed are in an orbit, wait 10 seconds and start decending
when ship:altitude > 70000 and ship:orbit = true then  {
    
    print "Waiting 10 seconds".
    wait 10.
    print "Starting to decend".
    
    set RCS:FOREBYTHROTTLE to true.
    set RCS:FOREENABLED to true.
    
    //check if we are in a orbit and lock the steering to either up or retrograde
    if ship:orbit = true {
        lock steering to retrograde.
        rcs on.
    } else {
        lock steering to up.
        rcs on.
    }

    //wait until we are at 40000 on the periapsis for a fuel efficient decend
    wait until ship:periapsis = 40000.
    
    when ship:periapsis < 40000 then {
        print "expect heating...".
        preserve.
    }

    //check if ship is too fast
    when ship:verticalspeed < 2000 and ship:altitude < 30000 then {
        print "Too fast!".

        //if the ship is already retrograde simply lock the steering and burn retrograde
        when ship:retrograde then {
            rcs on.
            
            sas on.
            set sasMode to retrograde.
            
            lock steering to retrograde.
            lock throttle to 1.0.
            wait until ship:verticalspeed < 1400.
            lock throttle to 0.0.
            unlock throttle.
        }

        //if the ship is prograde, enable rcs and sas and turn towards retrograde then burn retrograde
        when ship:prograde or ship:heading = not up then {
            print "ono".
            
            rcs on.
            
            sas on.
            set sasMode to retrograde.
            
            wait until ship:retrograde = true.
            
            when ship:retrograde = true then {
                lock throttle to 1.0.
                wait until ship:verticalspeed < 1400.
                lock throttle to 0.0.
                unlock throttle.
            }
        }
        preserve.
    }

    when ship:altitude < 2000 then {
        print "Next stage is parachutes... right?".
        stage.
        print "Staged".
    }
}
