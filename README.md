# Jaguar_MiSTer

Atari Jaguar FPGA core, written by Torlus.

Initial attempt to port to MiSTer.

It's using the later framework now, from a recent release of the GBA core.

Both analog video and HDMI are working, but the sync timings still need a few tweaks, so the image may be shifted slightly.

(or might not display correctly on an analog monitor.)


The proper Jag BIOS is now being used. If a cart is failing the checksum, a patch can skip the failure by selecting it in the menu. Testing was done with the M version of the BIOS.

A RESET (or new cart ROM load) is required after changing the Checksum patch option.

The patch allows more games to be tested with the BIOS, and shows the spinning cube logo now.

The BIOS file (usually "jagboot.rom") should be renamed to boot.rom or boot0.rom, then copied into the Jaguar folder on the SD card.

The CD BIOS must be loaded manually or automatically When using CDs (including VLM). The CD BIOS can be auto-loaded if named boot1.rom in the Jaguar folder.

The Memory Track cart is now supported. The ROM from the cart can be auto-loaded by naming it boot2.rom in the Jagaur folder. Permenace of the actual save data using the SD card is not yet implemented.

A binary cue file can be loaded to go with the CD image. The default assumes ULS formatted CDs with the 6 individual bin files loaded sequentially. The binary cue files are needed if not using a CDI image.


I've added a video mode switch to the OSD menu, which is normally a pin on the Jag motherboard that gets tied high or low.
(for NTSC or PAL mode.)

That signal gets read by the BIOS at start-up, so a RESET (or new cart ROM load) is required for the NTSC/PAL change to take effect.

It's possible that some games might detect the video mode, and refuse to boot if there is a region mismatch.

It does now change the video sync timings between NTSC and PAL, but the master clock frequency is fixed at 26.59 MHz atm,
so the sync timings might not be exactly per-spec for NTSC/PAL.


The controls for player 1 are now hooked up to MiSTer.

I tried hooking up player 2 before as well, but for some reason it stopped the core booting?


The core is now using SDRAM for cart loading and for main RAM as well as BIOSes and memtrack save data. So SDRAM is *required*.

The latency of SDRAM is a bit too high for more games to run cycle acurately with only one SDRAM module.


All known games now boot, some with glitches or no audio, and others that might crash to a black screen (but often the game keeps running).
 
 
The older j68 CPU core has been replaced with FX68K, which is claimed to be cycle-accurate, and has shown to be very accurate so far.
(on cores like Genesis). 
This has now been replaced with nuked's 68k core. The fx68k can be built by using a define, but differences in FC signals will cause inaccuracies including memtrack checksums to fail.

I added a Turbo option for the 68000 to the MiSTer OSD, which does help speed up some things, like the intro to Flashback.

It does not speed up the main "Tom and Jerry" custom chips, though, except for reducing wait states on ROM/BIOS access.

If a game doesn't work try turning on max compatibility or loading more than once.

In summary: still a fair bit of work to be done. lol

ElectronAsh.

Remaining tasks (No guarantees to complete)
- Data streaming through MiSTer Main (seems functional - needs more testing)
- Opening OSD can crash data streaming (bigger cache might help)
- Memory Track working (using Romulator/Alpine version - AMD or Atmel versions not needed?). Save data is not hooked up to SD card
- Weird timing display in VLM. Drops digits
- CD-G support
- DSP sometimes does not come up correctly even after reboot
- Quality of life improvements
- Other CD formats beside cdi (cue/bin, chd - not sure if this is possible as it requires multi-session)
- Single RAM improvement? Not sure if further improvement possible
- Re-add turbo support? Not sure if possible with nuked 68k
- Clean-up?

In summary: Getting close. lol
(updates GreyRogue)
