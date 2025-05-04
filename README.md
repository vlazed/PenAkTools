Collection of small lua scripts that may come in handy for Garry's Mod animation.

The Tools:
==========
Advanced Camera Manipulator tool
==========
Adds an "AdvCam Manipulator" tool that allows you to move Advanced Cameras and Soft Lamps by attaching them to yourself and moving with you, also allows to teleport yourself to the entity's position or its offset.

This tool is uploaded on steam workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2787625185

https://www.youtube.com/watch?v=SMtjvSXIxEc

Fakedepth post processing effect
==========
Edit of depth shader addon by ilikecreepers - https://steamcommunity.com/sharedfiles/filedetails/?id=2805432246
Allows to make depth render like effect, which could be useful for adding fog or DOF stuff in post editing. Edit allows this shader to work with skyboxes, makes it so render happens only once, so it doesn't get updated in realtime to save on resources, and has an option to add 3rd plane between original ones and color it.

https://www.youtube.com/watch?v=UaCVbICWNgA

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

This tool is uploaded on steam workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2888247176

https://www.youtube.com/watch?v=VGACqXq45q8

Ragdoll Unstretch
==========
Tool that is based on Standing Pose Tool, allows you to selectively return ragdoll's bones to "normal" positions. It is primarily meant to be used with Ragdoll Stretch Tool: https://steamcommunity.com/sharedfiles/filedetails/?id=529986984&searchtext

This tool is uploaded on steam workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=2587143550

https://www.youtube.com/watch?v=yf2g6Mihhe4

Static Prop Replacer
==========
LUA script that is meant to spawn in prop_dynamics in place of map's prop_static entities, it is meant to work together with "blackify" script. Uses NikNaks library https://steamcommunity.com/sharedfiles/filedetails/?id=2861839844

Console commands:
peak_sprep_replace - Spawns in prop_dynamics from the map you're on and hides static props, if replacer props were already spawned then it'll clear them and show static props

peak_sprep_replacefromfile [.txt with prop data] - Spawns in prop_dynamic from a json file that's stored in data/propreplace folder, if replacer props were already spawned then it'll clear them and show static props

peak_sprep_makepropdata - Takes static prop data from the map you're on and creates a json file in data/propreplace folder, this is primarily meant to be used as a way to edit out some of the static props, like if some props have to be removed

Has an older version with a python script made by Awsum N00b which extracts static prop data from map decompiles and turns them into files that the script uses.

https://youtu.be/2DhWY4V_yqQ

https://www.youtube.com/watch?v=7UQ_ie95Dl0

Very small scripts
==========
Various weird scripts I have that are meant to be run through lua_run or lua_run_cl console commands:

Chatty: Allows you to mimic someone saying stuff in gmod chat. Why? Why not?

Soft lamps grabber (clientside): Finds all soft lamps and opens their properties menu. I don't think anyone would find it useful apart from me lol.



I've also started making some small Python scripts for Blender, that allow me to speed up my video creation process in VSE:
BLENDER ADDONS
==========
All stuff in this folder is some sort of script for Blender that can be installed as an addon to it:

Fade in/out script
==========
Blender already has a feature to automatically do fade in and out on VSE strips, though mine allows to set fade in/out time in frames, and also offset it by a set amount of frames. Quite niche.

"Text Timer" script
==========
This is meant to work with Text strips, it will set their duration to about the time it should take to read out that text. It is possible to set time it takes per word, per "sentence" (will add time for every . ! ? that's not at the end of the text) and per commma that's not at the end of the sentence. By default it uses 0.3 seconds per word, and 0.1 seconds per sentences and commas. 0.3 seconds per word is used based on an assumption that average person reads 200 words per minute, so 200/60 = ~3,33 words per second, and 1/3,33 = 0,3003 seconds per word.
