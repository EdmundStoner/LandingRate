# LandingRateMx Beta


## A work in progress


This is version ES v0.7 (2023-03-01) of the LandingRateMx, FlyWithLua script, originally written by Dan Berry that includes added VR support by William R Good (SparkerInVR) based on initial work by Erhardma

This script is an X-Plane landing rate plugin that will analyze the data with what X-Plane and Lua provide to record and display the forces that occur during a landing. The most signifigant change from the original is, this version uses the datarefs that pertain to the wheel force. This also allows to display the maximum Lb's of force that was applied the gear during the landing. 

Also added, is an after-landing function to allow for the largest bounce to be recorded, rather than the first touch to the surface. This is currently set for 100 frames after the landing. If this needs to be adjusted it is READAFTERLANDING variable in the LandingRateMx.lua. 

There are a few other settings that are located in beginning of the LandingRateMx.lua file, such as, for the Pop up display  position, fonts and borderwidth, how long you would like to show the popup or not to show it at all and if you would like to record the landing to a logfile. BEWARE OF THE DRAGONS

Run the LandingRateMx Debug screen Macro, located in the X-Plane Plugins/Lua/Macr0 menu, to display a bunch of data in the lower left part of the flight window. This data will be green when you are ascending and red when you are descending.

On the debug screen, while the aircraft is stopped, in calm weather, look at the values for the weight and the force on the gear, they should be the same (well, pretty close). Check this weight against the weight in X-Plane's Weight and Balance window. Even though all of these values are created by X-Plane, they are not all exactly the same(?). 

You will also see that if the weight of the plane is more than the weight on the gear, the Gear G's will be less than 1.
If the aircraft weight is less the the force on the gear, the G's will be more than 1. 
The math is pretty simple:
#### GEAR-FORCE / WEIGHT = G's. 
Some examples of this would be that a landing a 1000lb plane, with a force of 2G's, will be a force of 2000lbs applied to the gear. 
Landing a 1000lb plane, with a force of .9G's, will be a force of 900lbs applied to the gear.
Large airliners and 4G carrier landings may result in millions of Lbs of force applied to the gear. It does not seem like the data used any shock absorbers, so this force that is applied to the wheel, not the gear as an assembly.


Use the File List to see when and what changes have been made to the files.
I will update the changelog and this ReadMe to explain some of the changes.

To get a zip of the files, click [here](https://github.com/EdmundStoner/LandingRate/archive/refs/heads/main.zip).

Use the ISSUE button, for bugs and suggestions
