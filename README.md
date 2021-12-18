# TRS-80_MC-10_DragonBoard
TRS-80 model MC-10 implementation for DragonBoard FPGA boards.  

This project is an FPGA implementation of the TRS-80 model MC-10 home computer. Most programs that ran on the original MC-10 should work on this project, and the custom FPGA boards have connectors that make it easy to load and store programs on a tape recorder. Video output is provided by a VGA port, and a PS/2 port is used for the keyboard.  

The project in MC10_DragonBoard is for DragonBoard versions 1.0 and 1.1. MC10_DragonBoard_V12 is for DragonBoard version 1.2.  
The two versions are incompatible because DragonBoard version 1.2 has a different pin assignment. This was done to correct an issue with the SDRAM clock.  
