Hard (not relying on unrelated instructions) Test Generator
========

Usage
--------

1. Write your test files in `/sim/source/` directory or its sub-directories. One test case per file. See `sample_test` as an example. **Your filename should be without suffix**.

2. Run `make` in root directory. You need to install MIPS cross-compiler before running this. The default compiler tool chain is `mipsel-linux-gnu` (el means little endian). If you are using other tool chain, change the `XCOMPLIER` constant in `build.py`. (How to install: `apt-get install gcc-mipsel-linux-gnu` for Ubuntu. Use "Linux sub-system" if using Windows)

3. Simulation files will be outputed to `/sim/output/` directory. One test case per sub directory. Add them **one by one** into Vivado, configure the test case ID for each of them.

NOTE: The VHDL 2008 is used in the test codes. Don't forget to set the file property after adding them (see issue #5)