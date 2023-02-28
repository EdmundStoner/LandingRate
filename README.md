# LandingRateMx Alpha

## This is a work in progress!

This is version 1 (2023-02-28) of the LandingRateMx, FlyWithLua script, originally written by Dan Berry that includes added VR support by William R Good (SparkerInVR) based on initial work by Erhardma

This script is an X-Plane 11/12 Landing rate plugin that will analyze the data that X-Plane datarefs and lua functions will use to record and display the forces that occur during a landing. 

In the LandingRateMx Debug screen(turn it on in the Lua Macro Menus), while the aircraft is stopped in calm weather, you will see that the weight and the force on the gear will be the same (well, pretty close) and this is in Kilograms, because that is what the datarefs typically use. Check this against the weight in X-Plane's weight and balance window. Even though all of these values are created by X-Plane, they are not all exactly the same(?). 

You will see on the Debug display, that if the weight of the plane is more than the weight on the gear, the Gear G's will be under 1. if the aircraft weight is less the the force on the gear, the G's will be more than 1. The math is pretty simple:
#### WEIGHT / GEAR-FORCE = G's. 
An example of this would be that a landing a 1000lb plane, with a force of 2G's, is a force of 2000lbs applied to the gear and a landing a 1000lb plane, with a force of .9G's, will be a force of 900lbs applied to the gear

Use the File List to see when and maybe what changes have been made to the files.
I will update the changelog and this ReadMe to explain some of the changes.

To get a zip of the files, click [here](https://github.com/EdmundStoner/LandingRate/archive/refs/heads/main.zip).
