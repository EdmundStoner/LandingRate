# LandingRateMx Alpha

## This is a work in progress!

X-Plane 11/12 Landing rate plugin that I have modified to analyze the forces that Xplane datarefs provide while landing the craft

This is version 1 (2023-02-28) of my LandingRateMx, FlyWithLua script, originally written by Dan Berry with added VR support by William R Good (SparkerInVR) based on initial work by Erhardma

I currently experimenting with functions to record and display the G's that occur during a landing. 

In the Debug screen you will see that the weight and the force on the gear will be the same (well, pretty close) and this is in Kilograms, becouse that is what the datarefs typically use. Check this against the weight in X-Plane's weight and balance window. Even though all of these values are created directly by X-Plane, the values are not all exact. 

if the weight of the plane is more than the weight on the gear, the Gear G's will be under 1. if the aircraft weight is less the the force on the gear, the Gear G's will be more than 1. 

The math is pretty simple: 
####          WEIGHT / GEAR-FORCE = G's. 
This means that landing 2 G's on a 1000 lb plane will be 2000 lbs of force applied to the gear.


To get a zip of the files, click [here](https://github.com/EdmundStoner/LandingRate/archive/refs/heads/main.zip).
