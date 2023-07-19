# Randomness Generation for Secure Hardware Masking - Unrolled Trivium to the Rescue

## Publication
This repository contains source code of hardware implementations related to a research paper titled "Randomness Generation for Secure Hardware Masking - Unrolled Trivium to the Rescue".

## Content of the Repository
In this repository we share RTL source code (VHDL) of "unrolled" stream cipher algorithms including Bivium B, Trivium, Kreyvium, Grain v1 (80-bit key), Grain v1 (128-bit key), MICKEY 2.0 (80-bit key) and MICKEY 2.0 (128-bit key). The degree of unrolling, and therefore the number of output bits produced per cycle, can be set via a VHDL Generic parameter to any positive integer. Our associated research paper advocates Trivium (and for lower or higher security demands also Bivium B and Kreyvium, respectively) for the secure and efficient generation of many pseudo-random bits per cycle from an initial seed for randomness-hungry masked hardware implementations. The asymptotic cost is estimated to be as low as 20 ASIC gate equivalents (GE) or 3 FPGA look-up tables (LUTs) per bit needed per cycle for Bivium B and 30 GE or 4 LUTs for Trivium (80-bit security).

## Contact and Support
Please contact Thorben Moos (thorben.moos@uclouvain.be) if you have any questions, comments or if you found a bug that should be fixed.

## Licensing
Please see `LICENSE.txt` for licensing instructions.