# Digital Techniques 3 Project: Audioport IP

This project covers the complete ASIC design flow for an I2S audio interface, from RTL design to physical layout.

## My Contributions

### RTL Design & HLS
* **Control Unit & CDC:** Designed the register map, control logic, and clock domain crossing synchronization using **SystemVerilog**.
* **I2S Unit:** Implemented the serial audio interface protocol in **VHDL**.
* **DSP Unit:** Generated the RTL implementation from a SystemC model using Catapult HLS.

### Verification
* **UVM Testbench:** Built a hierarchical verification environment covering both block and system levels:
  * **Control Unit (Block-Level):** Implemented the agent and custom sequences to verify register configuration and interrupt logic.
  * **Audioport (System-Level):** Built the top-level `audioport_env` by integrating multiple agents (`i2s`, `irq`, `apb`) and connecting the scoreboard.
* **Formal Verification & SVA:** Wrote SystemVerilog Assertions (SVA) and performed formal verification to validate control logic correctness.
* **CDC Analysis:** Verified clock domain crossings using static analysis tools to prevent metastability issues.
* **SystemC Validation:** Validated the DSP algorithms using a high-level SystemC model before RTL generation.

### Physical Implementation
* **Synthesis & DFT:** Performed logic synthesis and calculated/configured scan chains (DFT) for the design.
* **Layout:** Completed Place & Route using Cadence Innovus.

## Tools Used
* **Simulation:** Siemens QuestaSim
* **HLS:** Catapult HLS
* **Synthesis:** Synopsys Design Compiler
* **Layout:** Cadence Innovus
