# Hardware-Implementation-of-Modular-Arithmetic-for-RSA-FPGA

VHDL-based RSA modular arithmetic and 16-bit RSA core implemented on a Basys-3 FPGA.

## Description

This project implements the core modular arithmetic blocks required for the RSA cryptosystem in hardware. It includes modular addition, modular multiplication, and MSB-first modular exponentiation, all designed in VHDL and verified using self-checking testbenches.

The arithmetic blocks are integrated into a complete 16-bit RSA encryption/decryption core deployed on the Basys-3 FPGA. The project also demonstrates a hardware brute-force attack on a small RSA key space, highlighting the importance of large key sizes in public-key cryptography.

Developed under the supervision of **Prof. Yann Kieffer**, Grenoble INP – Esisar.

## Technologies

- VHDL  
- Basys-3 board  
- Vivado / ModelSim  

## Contributors

- **Thomas Ibrahim** — [@tomehabb](https://github.com/tomehabb)  
- **Kazi Aklima Sultana** — [@KASultana](https://github.com/KASultana)
