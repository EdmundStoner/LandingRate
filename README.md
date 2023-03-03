# LandingRateMx Beta


## A work in progress


This is version ES v0.75 (2023-03-02) of the LandingRateMx, FlyWithLua script, originally written by Dan Berry that includes added VR support by William R Good (SparkerInVR) based on initial work by Erhardma

This script is an X-Plane landing rate plugin that will analyze the data with what X-Plane and Lua provide to record and display the forces that occur during a landing. The most signifigant change from the original is, this version uses the datarefs that pertain to the wheel force. This also allows to display the maximum Lb's of force that was applied the gear during the landing. 

Also is an after-landing function to allow for the largest bounce to be recorded, rather than the first touch to the surface. After any wheel touches, the display comes up showing the rate that the wheel touched. The G's will continue to update until all of the wheels are down. If the nose wheel hits the ground with more G's, the higher G's will be shown. If you take off again (and remain under 15M), the second landing that happens will update the G's, if they are greater. There is a bit of error checking to determine that the G's are ok. If the show a difference, '?(Check Log)' will be added to the G's on the display. Both the calculated and displayed G's are logged. It won't be much!

There are ettings that are located in beginning of the LandingRateMx.lua file, such as, for the Pop up display position, fonts, bordercolor and borderwidth, how long to show the popup or not to show it at all and if you would like to record the landing to a logfile.  BEWARE OF THE DRAGONS

Run the LandingRateMx Debug screen Macro, located in the X-Plane Plugins/Lua/Macro menu, to display a bunch of data in the lower left part of the flight window. This data will be green when you are ascending and red when you are descending.

On the debug screen, while the aircraft is stopped, in calm weather, look at the values for the weight and the force on the gear, they should be the same (well, pretty close). Check this weight against the weight in X-Plane's Weight and Balance window. Even though all of these values are created by X-Plane, they are not all exactly the same(?). 

You will also see that if the weight of the plane is more than the weight on the gear, the Gear G's will be less than 1.
If the aircraft weight is less the the force on the gear, the G's will be more than 1. 

The math is pretty simple:
#### GEAR-FORCE / WEIGHT = G's. 

Some examples of this would be that a landing a 1000lb plane, with a force of 2G's, will be a force of 2000lbs applied to the gear. 
Landing a 1000lb plane, with a force of .9G's, will be a force of 900lbs applied to the gear.

Large airliners and 4G carrier landings may result in millions of KgM of force applied to the gear. It does not seem like the X-Plane datarefs use any shock absorbers, so this should be force that is applied to the wheel, not the gear as an assembly.


To get a zip of the files, click [here](https://github.com/EdmundStoner/LandingRate/archive/refs/heads/main.zip).

Use the File List to see when and what changes have been made to the files.
I will update the changelog and this ReadMe to explain some of the changes.

Use the ISSUE button, for bugs and suggestions
