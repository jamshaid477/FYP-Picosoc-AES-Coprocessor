# FYP - RISC-V Processor with AES Support

## Overview
This project implements a modified version of the open-source picorv32 RISC-V processor core, upgraded to support AES scalar cryptographic instructions. The design is part of a Final Year Project (FYP) and includes a testbench, program files, and a Makefile for hex generation.

## Files
- `picorv32_AES.v`: Verilog file for the modified picorv32 core with AES support.
- `tb_picorv32_aes.v`: Testbench Verilog file to verify the AES implementation.
- `program.hex`: Hex file for the RISC-V processor program.
- `program.s`: Assembly source file for the RISC-V program.
- `linker.ld`: Linker script for generating the hex file using gcc.
- `Makefile`: Makefile to compile and generate the hex file.

## Modifications
The picorv32 core has been extended to include custom AES scalar instructions. Key changes include:
- Addition of AES encryption/decryption instructions.
- Integration with the existing RISC-V instruction set.

## Build Instructions
1. Ensure a RISC-V GCC toolchain is installed.
2. Run `make` in the terminal to compile the assembly file and generate `program.hex` using the linker script.

## Testing
- Simulate the design using a Verilog simulator (e.g., Icarus Verilog) with `tb_picorv32_aes.v`.
- Verify AES operations against expected outputs.

## License
This project uses the picorv32 core under the ISC License. See the included LICENSE file for details.

## Acknowledgments
- Original picorv32 core by Clifford Wolf.
- Team member: Muhammad Salman (Electrical Engineer).
- Supervisor: Dr. Naureen Shaukat.
- FYP guidance and support from [your institution].