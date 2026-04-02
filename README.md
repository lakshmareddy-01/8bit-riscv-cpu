# 8-bit RISC-V Inspired Multi-Cycle CPU

This project implements a simplified 8-bit RISC-V inspired CPU using a multi-cycle architecture. The design includes a complete RTL implementation, verification testbenches, and a full ASIC implementation flow using the SkyWater 130nm open-source PDK.

## Overview

The CPU is a reduced 8-bit version of RISC-V with a 16-bit instruction word, featuring:

- 8-bit datapath with 16-bit instructions
- 8 general-purpose registers (r0-r7)
- Multi-cycle implementation with 5 stages (Fetch, Decode, Execute, Memory, Writeback)
- Harvard-like architecture with separate instruction and data paths
- Implements R-type, I-type, load/store, branch, and jump instructions
- Complete physical implementation targeting SkyWater 130nm technology

## Prerequisites

- Icarus Verilog or other Verilog simulator for running testbenches
- GTKWave for viewing simulation waveforms
- Yosys for RTL synthesis
- OpenSTA for static timing analysis
- OpenROAD for physical design (includes the SkyWater 130nm PDK)

## PDK Information

This project uses the SkyWater 130nm (sky130) open-source PDK. The necessary PDK configuration files are included in the `pdk/` directory. The large PDK libraries themselves are not included in this repository due to their size.

**Important Note:** If you're using OpenROAD, you don't need to install the SkyWater PDK separately as it's already integrated with the OpenROAD installation. The configuration files in this repository are set up to work with OpenROAD's integrated PDK.

## Script Execution

All scripts in the repository are configured to be executed from the **project root directory**. The paths within the scripts are set accordingly. 

For example, to run synthesis:
```bash
# From the project root directory
yosys -c scripts/synthesis/synthesis.tcl
```

Similarly for physical design and other steps:
```bash
# From the project root directory
openroad scripts/pd/floorplan/floorplan_impl.tcl
```

This consistent path structure ensures that all scripts can find their required files regardless of which step you're running.

## Directory Structure

### RTL Source Code
- `rtl/` - RTL Verilog files for the CPU modules
  - `alu.v` - Arithmetic Logic Unit implementation
  - `control_unit.v` - Multi-cycle control unit with state machine
  - `cpu_top.v` - Top-level CPU module with interconnections
  - `immediate_gen.v` - Immediate value generator for different instruction types
  - `instruction_decoder.v` - Instruction decoder for 16-bit instructions
  - `memory_interface.v` - Memory interface with unified address space
  - `program_counter.v` - Program Counter module
  - `register_file.v` - 8-register (r0-r7) register file

### Verification
- `testbench/` - Verification testbenches
  - `alu_tb.v` - ALU testbench
  - `control_unit_tb.v` - Control unit testbench
  - `cpu_top_tb.v` - Top-level CPU integration testbench
  - `immediate_gen_tb.v` - Immediate generator testbench
  - `instruction_decoder_tb.v` - Instruction decoder testbench
  - `memory_interface_tb.v` - Memory interface testbench
  - `program_counter_tb.v` - Program counter testbench
  - `register_file_tb.v` - Register file testbench

### Design Constraints
- `constraints/` - Timing constraints for synthesis and place & route
  - `cpu_top.sdc` - SDC timing constraints file

### Implementation Scripts
- `scripts/` - Flow automation scripts
  - `synthesis/` - Synthesis scripts
    - `synthesis.tcl` - Yosys synthesis script
  - `sta/` - Static timing analysis
    - `run_sta.tcl` - OpenSTA timing analysis script
  - `pd/` - Physical design flow scripts
    - `flow.tcl` - Main flow script for OpenROAD
    - `flow_helpers.tcl` - Helper functions for the PD flow
    - `helpers.tcl` - General helper functions
    - `floorplan/` - Floorplanning scripts
      - `floorplan_impl.tcl` - Floorplan implementation
      - `floorplan_setup.tcl` - Floorplan configuration 
    - `pdn/` - Power Distribution Network scripts
      - `pdn_impl.tcl` - PDN implementation script
      - `pdn_setup.tcl` - PDN configuration
    - `placement/` - Cell placement scripts
      - `placement_impl.tcl` - Placement implementation
      - `placement_setup.tcl` - Placement configuration
    - `cts/` - Clock Tree Synthesis scripts
      - `cts_impl.tcl` - CTS implementation
      - `cts_setup.tcl` - CTS configuration
    - `routing/` - Routing scripts
      - `routing_impl.tcl` - Detailed routing implementation
      - `routing_setup.tcl` - Routing configuration
    - `final/` - Final steps scripts (DRC, extraction)
      - `final_impl.tcl` - Final implementation steps
      - `final_setup.tcl` - Final step configuration

### PDK Configuration
- `pdk/` - SkyWater 130nm PDK configuration
  - `sky130hd/` - SkyWater HD (high density) library
    - `sky130hd.pdn.tcl` - PDK-specific PDN configuration
    - `sky130hd.rc` - RC parasitics configuration
    - `sky130hd.rcx_rules` - Extraction rules
    - `sky130hd.tracks` - Routing track definitions
    - `sky130hd.vars` - PDK variables for OpenROAD
    - Various library symlinks and configuration files

### Documentation
- `docs/` - Documentation
  - `8-bit RISC-V Inspired Multi-Cycle CPU_ Final Specifications.pdf` - Detailed project specifications

### Results (Generated)
- `results/` - Results from running the tools (not in repository)
  - `sim/` - Simulation results
    - `bin/` - Compiled simulation binaries
    - `waves/` - Waveform output files
  - `synthesis/` - Synthesis results
    - `netlist/` - Generated netlists
    - `reports/` - Synthesis reports
    - `schematics/` - Generated schematics
  - `sta/` - Static timing analysis results
    - `reports/` - Timing reports
  - `pd/` - Physical design results
    - Subdirectories for each step of the physical design flow

## Running Simulations

The project includes testbenches for individual modules and the complete CPU. To run a simulation:

```bash
# Create output directories if they don't exist
mkdir -p results/sim/bin
mkdir -p results/sim/waves

# From the project root directory:

# To run the full CPU testbench:
iverilog -o results/sim/bin/cpu_top_tb rtl/cpu_top.v rtl/*.v testbench/cpu_top_tb.v
vvp results/sim/bin/cpu_top_tb

# To run individual module testbenches (example for ALU):
iverilog -o results/sim/bin/alu_tb rtl/alu.v testbench/alu_tb.v
vvp results/sim/bin/alu_tb

# View waveforms (if your testbench dumps VCD files):
gtkwave results/sim/waves/cpu_top_tb.vcd
```

The testbenches verify various aspects of the design:
- `alu_tb.v` - Tests all ALU operations and flag generation
- `control_unit_tb.v` - Tests state transitions and control signal generation
- `cpu_top_tb.v` - Tests complete CPU execution of the test program
- `immediate_gen_tb.v` - Tests immediate value generation for all instruction types
- `instruction_decoder_tb.v` - Tests instruction field extraction
- `memory_interface_tb.v` - Tests memory read/write operations
- `program_counter_tb.v` - Tests PC update logic
- `register_file_tb.v` - Tests register reads and writes with register 0 hardwired to 0

The test program loaded into memory implements:
1. Loading constants into registers
2. Adding values
3. Storing to memory
4. Loading from memory

## Running Synthesis

Synthesis is performed using Yosys. The project includes a synthesis script:

```bash
# From the project root directory:
yosys -c scripts/synthesis/synthesis.tcl

# If the script encounters errors, run Yosys in interactive mode instead:
yosys
```

The synthesis script (`synthesis.tcl`) performs these operations:
- Reads the SkyWater PDK liberty file
- Reads all RTL source files
- Performs hierarchy checking
- Converts processes to netlist primitives
- Maps memories to flip-flops
- Performs optimization passes
- Maps to SkyWater 130nm technology cells
- Generates netlists in the `results/synthesis/netlist/` directory

The synthesis process also generates useful reports and schematics viewable in your browser or graphical tools.

After synthesis, you can verify the generated netlist with functional simulations, or proceed to Static Timing Analysis (STA).

## Static Timing Analysis

You can run Static Timing Analysis (STA) on the synthesized design using OpenSTA:

```bash
# From the project root directory:
sta scripts/sta/run_sta.tcl
```

This will generate timing reports in the `results/sta/reports/` directory, including:
- Setup time analysis (max delay)
- Hold time analysis (min delay)  
- Power analysis

## Running Physical Design Flow

The physical design flow consists of multiple steps, each with dedicated scripts:

1. **Floorplan** - Define die area and core area
   ```bash
   # From the project root directory:
   openroad scripts/pd/floorplan/floorplan_impl.tcl
   ```

2. **Power Distribution Network** - Create power grid
   ```bash
   openroad scripts/pd/pdn/pdn_impl.tcl
   ```

3. **Placement** - Place standard cells
   ```bash
   openroad scripts/pd/placement/placement_impl.tcl
   ```

4. **Clock Tree Synthesis** - Build balanced clock distribution
   ```bash
   openroad scripts/pd/cts/cts_impl.tcl
   ```

5. **Routing** - Connect cells with wires
   ```bash
   openroad scripts/pd/routing/routing_impl.tcl
   ```

6. **Final Steps** - Add filler cells, perform extraction, generate final outputs
   ```bash
   openroad scripts/pd/final/final_impl.tcl
   ```

For convenience, you can run the complete flow using the main flow script:
```bash
openroad scripts/pd/flow.tcl
```

Each step produces output files in the corresponding subdirectory under `results/pd/`. You can inspect DEF files using tools like KLayout, or view timing reports in the `reports` subdirectories.

## Instruction Set

The CPU implements these instruction types:
- R-Type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA
- I-Type: ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, LUI
- Load/Store: LB, LH, SB, SH
- Branch: BEQ, BNE, BLT, BGE
- Jump: JAL, JALR

