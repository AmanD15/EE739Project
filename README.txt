AUTHORS

Aman Dhammani : 18D180002
Deep Satra : 180040030

-----------------------------------------------------------------------------------------------------------------------------------
AIM

The aim is to design a 6 stage pipelined processor, whose instruction set architecture was provided. It is a 16-bit computer system with 8 registers. The architecture should be optimized
for performance and should include hazard mitigation techniques.

-----------------------------------------------------------------------------------------------------------------------------------
DESCRIPTION

Forwarding and basic branch prediction is accomplished. Appropriate stall instructions are added to mitigate control and data hazards. The testbench is written for generating the initialization signals, loading instructions into instruction memory and checking the outputs. Entire code was compiled and netlist was viewed in Quartus.

The file names and their descriptions are:

packages.vhdl : Defines memory entity (can give 16bit data at a time)

VSCPU.vhd : Forms the wrapper architecture of the system. It takes the input fro the testbench, generates appropriate intermediate signals, contains the execution of system reset and restart. Instantiates the dataflow model of all 6 stages of pipeline. Code for handling stalls in case of control hazard and data hazard is included. 

IF.vhd : Handles Instruction fetch stage and updates program counter to PC+1 if there was no branch type instruction. If there is control hazard, i.e. branch had to be taken or jump instruction, the program counter is updated accordingly, and incorrectly fetched instructions are flushed from the system.

ID.vhd : Reads the fetched instruction, and decodes the instruction, giving the op_code, register a, register b, register c, condition (cz) etc., whichare fed to other stages for getting control and data signals.

RA.vhdl : The file contains the multi-port register file, and the design for the register access stage and the write_back stage. Since each stage is independent, this component will have separate stall logic for each stage. For write-back, the enable line for register write is checked, and based on the mode (single-register write or multi-register write like load multiple), the appropriate registers are written into with the values. The register access part reads the necessary registers and appropriately sign-extends the immediate operands, and sends the data into the 128-bit data channel, which is used by the ALU for computation. Additionally, it receives the signals from the execute and memory access stages to be used for data forwarding. The control signals for data hazards are generated using the address of the forwarded data and the current read addresses. It also sends the control signals for memory access, including load/store instructions, address of memory, number of memory locations to be updated. It also sends the necessary signals like the program counter, op_code, write-back address etc.

EX.vhd : The file stores the component for the execute stage of the pipeline. It contains the carry and zero flags, which are accessed and modified as required by the instruction. It performs the operation as defined by the op-code, and sets the required flag. Additionally, it computes the write-back address and transmits the necessary enable, address and data signals for memory access and write-back. The component also computes the program counter of the next instruction, which is then compared with the PC of the instruction in the decode stage to check for and correct control hazards. All the data is passed through a 128-b interconnect to maintain uniform data channel to suport all instructions.

MA.vhd : The file instantiates the 8-port memory required to facilitate instructions like load, store and their variants: multipl,all. It accesses the memory according to the signals received from the previous pipeline stage, and forwards the appropriate data, register addresses and enable signals for write-back stage . If there are no memory operations, it forwards the data from ALU to the next stage. Like ALU and RA, all the data passes through a 128-b interconnect, maintaining an uniform data channel to suport all instructions.

TB_VSCPU.vhd : This file is the testbench for the DUT to run. It instantiates the DUT, sends the reset flag, writes some instructions to the instruction memory and sends the start flag to let the processor start. It also generates and transmits the clock signal for the system to operate.

---------------------------------------------------------------------------------------------------------------------------------
DEPLOYMENT AND EXECUTION

To run the project, load the .qpf file as a Quartus project and compile the design. The design can then be simulated on Modelsim.

---------------------------------------------------------------------------------------------------------------------------------
GENERATED RESULTS 

The following image files are attached:
    rtl_netlist.png : Displays the RTL netlist for the generated system
    waveforms1.png : Shows a subset of waveforms for the signals generated by the testbench and the DUT
    waveforms1.png : Shows another subset of waveforms for the signals generated by the DUT
