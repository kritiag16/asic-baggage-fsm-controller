# ASIC-Based Automated Baggage Weighing Controller

## Overview
This project implements a Mealy finite state machine (FSM)-based digital controller for an automated airport baggage weighing and tagging machine.

The design follows synthesizable RTL practices and separates control logic from datapath modules.

## Problem Statement
The controller:
- Reads digital weight from load cell
- Compares against class-specific baggage limits
- Calculates excess fee
- Handles payment confirmation
- Prints baggage tag
- Logs transactions
- Detects fault conditions (sensor, printer, overload)
- Supports maintenance mode

## Architecture

### Control Unit (FSM)
- Mealy FSM implementation
- 10 states (IDLE, READ_WEIGHT, CHECK_WEIGHT, ERROR_STATE, etc.)
- Handles normal and fault transitions

### Datapath
- Weight register
- Class-based limit selection
- Excess fee computation
- Logging registers

## Verification
- Dedicated testbench
- Multiple simulation scenarios:
  - Within limit
  - Overweight
  - Maintenance mode
- Waveform verification included

## ASIC Flow

### Simulation Waveforms
The following images show the output of the testbench verifying correct state transitions and datapath behavior:
- `waveforms/simulation_waveform1.png`
- `waveforms/simulation_waveform2.png`
  
### Synthesis
- Tool: Cadence Genus
- Area and timing reports generated

### Physical Design
- Floorplanning and power planning in Innovus
- Placement, CTS, routing completed
- Post-CTS timing analysis performed

### Timing Signoff
- Debugged in Tempus
- No violating paths after optimization

## File Structure
- `rtl/` → Synthesizable Verilog modules
- `tb/` → Testbench
- `synthesis/` → Genus reports
- `pnr/` → Innovus layout screenshots
- `timing/` → Tempus timing summaries
- `waveforms/` → Simulation output

## Tools Used
- Cadence Genus
- Cadence Innovus
- Cadence Tempus
- Verilog HDL
