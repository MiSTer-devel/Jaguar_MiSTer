JagNetlists (c) 2013 Gregory Estrade 
All rights reserved (until I sort out the licensing stuff).

================================================================================
About
================================================================================
This project is a port of the Atari Jaguar chipset to a Stratix-II FPGA.
It features the Tom & Jerry chips, and a 68000 core.
Tom & Jerry designs have been converted from the original "netlists" files 
to Verilog HDL, using a compiler/translator tool that I wrote. 
It runs on a Nios-II Development Kit - Stratix edition (RoHS) board, with the
addition of a daughterboard that features a 24-bit VGA DAC.
The 68000 core (J68), the daughterboard and so much more are courtesy from
Frederic Requin a.k.a frenchshark. I owe much to him, as this project would
not have seen the light of the day without his advice.

================================================================================
History
================================================================================
A year or so ago, I found myself getting interested in the Jaguar console (don't
ask why). I started a rewrite of the chipset in VHDL, as well as writing the
translation tool, that was solely intended to simulation and verification.
I got myself a bit familiar with the Jaguar's architecture, but I eventually
went into a dead end, as I didn't own at this time a FPGA board powerful enough.
Also, it seemed to me that the time and effort required to get a reasonable
accuracy was way too high...

Then, at a retrocomputing event (VieuMikro), Frederic and I were talking about
our projects, and from this moment, many things happened:
- Frederic was (is) working on an Amiga core, and for this purpose designed 
the J68, a lightweight but full-featured 68000 core written in Verilog.
- He switched from VHDL to Verilog, and convinced me to do so, because of the
largest set of tools available, especially Verilator, which is amazing.
- Apart from the J68 core, he developed some cool software to use with
Verilator, such as a 68000 disassembler.
- Finally he found an eBay shop selling these Stratix-II boards for a low
price, and I purchased one of them.

It was then the right time to give this project a new try. And when I got myself
into what was possible with Verilator (due to its easy software integration and 
speed), I then thought that using the original netlist could be possible not 
only as a reference, but for synthesis as well..

================================================================================
Gregory Estrade, 05/10/2013
