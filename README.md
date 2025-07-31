# [Jaguar](https://en.wikipedia.org/wiki/Atari_Jaguar) for [MiSTer Platform](https://github.com/MiSTer-devel/Main_MiSTer/wiki)

Atari Jaguar FPGA core, written by Torlus.

Port to MiSTer by GreyRogue, Kitrinx & ElectronAsh

## Hardware Requirements
SDRAM of any size is required, dual SDRAM is preferred.

## Features
⦁	[Jaguar CD](https://en.wikipedia.org/wiki/Atari_Jaguar_CD) (cdi)
⦁	Team Tap multitap (5 players)
⦁	Spinner Controllers
⦁	Mouse (Atari ST)
⦁	Analog Joysticks
⦁	Jag Link (USERIO0 = RX, USERIO1 = TX)
⦁	Game Saves
⦁	Cheats


## Remaining tasks (No guarantees to complete)
⦁	Data streaming through MiSTer Main (seems functional - needs more testing)
⦁	Opening OSD can crash data streaming (bigger cache might help)
⦁	Memory Track not working (probably commercial BIOS does not support Romulator/Alpine - need to switch to AMD or Atmel)
⦁	Weird timing display in VLM. Drops digits
⦁	CD-G support
⦁	DSP sometimes does not come up correctly even after reboot
⦁	Quality of life improvements like boot rom loading of CD BIOS (and memory track ROM)
⦁	Other CD formats beside cdi (cue/bin, chd - not sure if this is possible as it requires multi-session)
⦁	Single RAM improvement? Not sure if further improvement possible
⦁	Re-add turbo support? Not sure if possible with nuked 68k
⦁	Clean-up?
In summary: Getting close. lol
(updates GreyRogue)
