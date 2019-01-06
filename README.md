# Tool for Analysis of Surface Cracks (TASC)

Tool for Analysis of Surface Cracks (TASC) is a computer program created in MATLAB to enable easy computation of nonlinear J-integral solutions for surface cracked plates in tension by accessing and interpolating between the 600 nonlinear surface crack solutions documented in NASA/TP-2011-217480.
TASC is a standalone executable program available for Windows 64-bit and macOS 64-bit.
Individual users of the standalone executables do not need a MATLAB license due to the royalty-free MATLAB Complier Runtime (MCR) distribution provided with the program installation package.

## Installation

Download the appropriate installation package (`TASC_(version)_Win64_pkg.zip` or `TASC_(version)_Mac64_pkg.zip`) for your operating system.
Installation details are in the readme.txt file included in the distribution package.
The correct version of the MCR package must first be installed on each computer on which you want to run TASC.
The correct MCR installation file (`MCRInstaller.exe`) is included in the distribution package.
The TASC standalone executable file (`TASC_(version).exe` for Windows and `TASC_(version)_mac.app` for Mac) can be located in any convenient place on your computer.

## Usage

Double click `TASC_(version).exe` for Windows or execute `run_TASC_(version)_mac.sh` from the terminal for Mac to start TASC.
The first time you run TASC, a start up window will appear stating "I have read and accept the terms of the NASA Open Source Agreement included in the TASC distribution package."
You must select "Yes" to run TASC. Selecting "Yes" creates a small text file, `TASC_lic.txt` in your executable directory.
You will not be asked to accept the agreement again unless you move or copy the executable file to another directory.

Example TASC input files (`*.ntrp`), material property files (`*.prop`), and test data files (`*.txt`) for both US and SI units are included in the `Distribution_Example_Files` directory.  The use and description of these files are explained later in this manual.

## Technical Notes

The GUI was created and formatted on the Windows platform.  As a result, on the Mac platform the GUI appearance for items such as  font sizes are not optimized.  In addition the Mac version does not have the capability to save an Excel summary of the results in `*.xlsx` format.  The results are output in text format and drop cleanly into Excel if so desired.  Also the Mac version does not have the ability to save plot images in the `*.emf` format so instead defaults to the `*.tiff` format.

## References

Background information on surface crack tension testing is documented in [ASTM E2899, Standard Test Method for Measurement of Initiation Toughness in Surface Cracks Under Tension and Bending](https://www.astm.org/Standards/E2899.htm), which is available from ASTM, <http://www.astm.org>.
