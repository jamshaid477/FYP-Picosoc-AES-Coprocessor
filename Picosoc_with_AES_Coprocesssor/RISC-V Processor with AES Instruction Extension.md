### Step-by-Step Guide to Implement PicoSoc on Spartan 6 Using Xilinx ISE 14.7

#### Step 1: Install Xilinx ISE Design Suite 14.7
Ensure that you have Xilinx ISE 14.7 installed on your system. This toolchain is required for Spartan 6 FPGA development.

#### Step 2: Prepare the Files
- Place the modified files (`hx8kdemo.v`, `spartan6_spram.v`, `Makefile`, and `spartan6demo.ucf`) in your project directory.
- Include the `picosoc.v` and `picorv32.v` files from the repository as dependencies.

#### Step 3: Create a New Project in ISE
1. Open Xilinx ISE Design Suite.
2. Create a new project named `spartan6demo`.
3. Select the Spartan 6 device (e.g., `xc6slx16-csg324`).
4. Add the Verilog source files (`hx8kdemo.v`, `spartan6_spram.v`, `picosoc.v`, `picorv32.v`) and the constraint file (`spartan6demo.ucf`).

#### Step 4: Run Synthesis
1. Open the "Synthesis" process for the top-level module `hx8kdemo`.
2. Ensure there are no errors or warnings related to Spartan 6 primitives.

#### Step 5: Implement Design
1. Run "Translate," "Map," and "Place & Route" processes in sequence.
2. Verify that all constraints are met.

#### Step 6: Generate the Bitstream
1. Run "Generate Programming File" to create the `spartan6demo.bit` file.

#### Step 7: Program the FPGA
1. Connect your Spartan 6 FPGA board to your computer.
2. Use the "iMPACT" tool in ISE to program the FPGA with the generated `spartan6demo.bit` file.

#### Step 8: Test the Design
- Test the UART communication (ser_tx, ser_rx) and verify the LED outputs.

Congratulations! You have successfully implemented PicoSoc on Spartan 6 FPGA.