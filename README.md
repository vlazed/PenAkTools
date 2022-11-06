Collection of small lua scripts that may come in handy for Garry's Mod animation.

The Tools:
==========
Advanced Camera Manipulator tool
==========
Adds an "AdvCam Manipulator" tool that allows you to move Advanced Cameras and Soft Lamps by attaching them to yourself and moving with you, also allows to teleport yourself to the entity's position or its offset.

Light Origin Tool + Turn into Dynamic Prop Tool
==========
Allows you to easily set lighting origin for ragdolls and dynamic props (Works even for entity's bonemerged stuffs. Doesn't work on physics props).

This tool is uploaded on steam workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2591866528

https://www.youtube.com/watch?v=dNIv49caXlM

https://www.youtube.com/watch?v=q_lFPTFm9GI

Lightbounce script + macro
==========
Overcomplicated macro for Pulover's Macro Creator that would allow to automate taking Soft Lamp's lightbounce passes for Stop Motion Helper animations and a little lua script to get a mark on your HUD, which is meant for that macro. + Wiremod Expression 2 chip for teleporting player to the Soft Lamp's position and angles.

https://youtu.be/4AetyXCdy_Y?t=235

Script for manipulating specific eye shader's eye dilation
==========
LUA  script that works for specific .vmt eye materials that allows you to manipulate their "dilation" through console. As an example, uses edited eye textures from Chonch's upscaled eye pack https://steamcommunity.com/sharedfiles/filedetails/?id=1742006887

https://youtu.be/4AetyXCdy_Y?t=419

"Macro Replacement" Script
==========================
Script that adds "Macro Replacer" tab under "Peak Incompetence" category in gmod's utilities menu, that allows you to run console commands on loop with specific delays. Primary function for it is to run screenshot commands and advance SMH's animation by a frame, basically what smh_makejpeg does, but more customizable. Pairs quite well with material manipulation script below.

Currently it has a bug with UI that seems to happen if you click on the text entry box and click on the macro replacer tab.

I was thinking I could put it into SMH sometime later.

https://www.youtube.com/watch?v=YQUmgGY1Pds

Material manipulation script for Stop Motion Helper
==========
Script which is meant to help out with the screenshot based rendering in stop motion helper, which allows playback of specific animated materials that were setup to work with the script through console. Also comes with a macro for Pulover's Macro Creator, as it doesn't work with Stop Motion Helper's own makescreenshot commands.

https://www.youtube.com/watch?v=xbLaRaxnG0U

https://www.youtube.com/watch?v=i4THjugoOUg

Ragdoll Weight Tool
==========
Tool that allows to set weight for individual bones on ragdolls, or set weight to be a specific numbers for all ragdoll bones. Primarily made to allow to stretch ragdolls more, as setting it to about more than 30kg on bones that had "snap back" stuff going on prevents them from doing that.

Ragdoll Unstretch
==========
Tool that is based on Standing Pose Tool, allows you to selectively return ragdoll's bones to "normal" positions. It is primarily meant to be used with Ragdoll Stretch Tool: https://steamcommunity.com/sharedfiles/filedetails/?id=529986984&searchtext

This tool is uploaded on steam workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2587143550

https://www.youtube.com/watch?v=yf2g6Mihhe4

Static Prop Replacer
==========
LUA script that is meant to spawn in prop_dynamics in place of map's prop_static entities, it is meant to work together with "blackify" script. It also has a python script made by Awsum N00b which extracts static prop data from map decompiles and turns them into files that the script uses.

https://www.youtube.com/watch?v=7UQ_ie95Dl0

Very small scripts
==========
Various weird scripts I have that are meant to be run through lua_run or lua_run_cl console commands:

Chatty: Allows you to mimic someone saying stuff in gmod chat. Why? Why not?

Soft lamps grabber (clientside): Finds all soft lamps and opens their properties menu. I don't think anyone would find it useful apart from me lol.
