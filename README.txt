Aman Dhammani : 18D0
Deep Satra : 180040030

The aim is to design a 6 stage pipelined processor, whose instruction set architecture was provided. It is a 16-bit computer system with 8 registers. The architecture should be optimized
for performance and should include hazard mitigation techniques.

Forwarding and basic branch prediction is accomplished. Testbench is written for checking. Entire code was compiled and netlist was viewed in Quartus.

The file names and their descriptions are:
packages.vhdl : Defines memory entity (can give 16bit data at a time)
VSCPU.vhd : Calls all 6 stages of pipeline synchronously at rising edge of the clock. Code for handling stalls in case of control hazard is included. Write back stage is implictly carried out in RA.vhdl and MA.vhd files
IF.vhd : Handles Instruction fetch stage and updates program counter to PC+1 if there was no branch type instruction. If branch had to be taken, program counter is updated accordingly.
ID.vhd : Forwards sections of instruction like op_code, register a, register b, register c, condition (cz) to other stages for getting control signals for further stages.

