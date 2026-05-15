SystemVerilog RTL & Verification Portfolio

Sudeep Kakade · MS ECE @ Rutgers University
SystemVerilog · UVM · Formal Verification · FPGA · RISC-V

This repository is a curated collection of RTL design and verification projects spanning protocol verification, processor design, formal property checking, FPGA implementation, and UVM register abstraction. Each folder is a standalone project with its own source, testbench, and documentation.

Projects
1. AXI4 Protocol Verification
/AXI Project
Full UVM-based verification environment for an AXI4 Full Slave implementation.
DUT5-channel AXI4 Full Slave with per-channel FSMs (AW/W/B/AR/R), byte-lane steering via wstrb, FIXED/INCR/WRAP burst modes with wrap-boundary computation, SLVERR/DECERR error responsesUVM Envuvm_config_db virtual interface propagation · directed sequences for FIXED/INCR/WRAP bursts and error injection · reference-model scoreboardCoverage95%+ functional coverageFormalSVA property suite in Jasper Gold — proved valid/ready deadlock freedom, burst boundary invariants, SLVERR/DECERR response correctnessToolsSynopsys VCS · Jasper Gold
Key skills demonstrated: UVM architecture, constrained-random stimulus, functional coverage closure, formal property checking

2. 5-Stage Pipelined RISC-V CPU Core
/Processor
RV32I pipeline implementation with full hazard handling.
Architecture5-stage pipeline: IF / ID / EX / MEM / WBISARV32I — R, I (LW/JALR), S (SW), B-type (BEQ/BNE/BLT/BGE) instructionsHazard HandlingLoad-use stall detection · EX/MEM→EX and MEM/WB→EX forwarding MUXes · branch-taken pipeline flushVerificationSelf-checking testbench targeting RAW hazards, load-use stalls, and branch resolutionToolsEDA Playground
Key skills demonstrated: Processor microarchitecture, pipeline hazard detection and forwarding, RTL control design

3. Formal SVA Verification
/Formal SVA
SystemVerilog Assertion (SVA) property suites for formal model checking.
MethodProperty-based model checking — covers safety, liveness, and protocol correctness propertiesToolsJasper Gold · Synopsys VC FormalFocusCDC correctness across asynchronous clock boundaries · handshake protocol invariants
Key skills demonstrated: SVA syntax, formal proof strategy, CDC verification, Jasper Gold flows

4. FPGA Image Processing
/FPGA Image Processing Project
Real-time image processing pipeline implemented and deployed on FPGA.
ImplementationPixel-level processing pipeline with BRAM inference for frame bufferingTargetXilinx FPGA — synthesized and implemented in VivadoTechniquesBRAM inference · pipelined datapath · timing closureToolsXilinx Vivado
Key skills demonstrated: FPGA implementation flow, BRAM inference, RTL synthesis and timing closure

5. Communication Protocols
/Protocols
RTL implementations of standard communication protocols.
ProtocolDescriptionUARTConfigurable baud rate, TX/RX with start/stop bit framingSPIMaster/slave modes, configurable CPOL/CPHAI2CStart/stop condition generation, ACK/NACK handlingAPBAPB slave with setup/access phase FSM
Key skills demonstrated: Protocol FSM design, serial interface RTL, self-checking testbenches

6. UVM Register Abstraction Layer (RAL)
/UVM_ral
UVM-RAL based register model for DUT-agnostic register verification.
Approachuvm_reg_block register model · frontdoor and backdoor access sequencesCoverageRegister field-level functional coverageReuseDesigned for DUT-agnostic reuse across multiple register maps
Key skills demonstrated: UVM-RAL architecture, register verification methodology, reusable verification IP

Repository Structure
Verilog---Portfolio/
├── AXI Project/              # AXI4 Full Slave DUT + UVM env + Jasper Gold SVA
├── FPGA Image Processing Project/  # Real-time image pipeline on Xilinx FPGA
├── Formal SVA/               # SVA property suites for formal model checking
├── Processor/                # 5-stage RV32I pipelined CPU core
├── Protocols/                # UART, SPI, I2C, APB RTL implementations
├── UVM_ral                   # UVM Register Abstraction Layer environment
└── README.md

Skills Across This Portfolio
DomainTools & ConceptsVerificationUVM · CRV · Functional Coverage · SVA · Formal Verification · Self-checking TestbenchesRTL DesignSystemVerilog · FSM Design · Pipeline Hazard Handling · BRAM InferenceFormal ToolsJasper Gold · Synopsys VC FormalSimulationSynopsys VCS · QuestaSim · Cadence Xcelium · EDA PlaygroundFPGAXilinx Vivado · XDC Constraints · Timing ClosureProtocolsAXI4 · APB · UART · SPI · I2C · RISC-V RV32I

Author
Sudeep Babasaheb Kakade
MS ECE · Rutgers University · GPA 3.75
LinkedIn · GitHub · saikakade501@gmail.com

🎯 Seeking Fall 2026 / Spring 2027 co-op in Design Verification or RTL Design for SoC/ASIC teams.
