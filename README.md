# Code 128 barcode generator
## Project description
This x86-64 and C hybrid program generates a barcode from a given string and saves it as a BMP file.

## Requirements
- CMake - build the project
- NASM - compile assembly code.
- GCC - C++ compiler.

## Installation
To install the required tools, open Linux terminal or Ubuntu session in Windows terminal, then enter the following commands:
```sh
sudo apt update
sudo apt upgrade
sudo apt install gcc gcc-multilib nasm make
```

## Usage
Clone the repository.
```sh
git clone https://github.com/simonnxyz/code128-generator-x86-64.git
cd code128-generator-x86-64
```
Build the project with simple command:
```sh
make
```
Run the executable file.
```sh
./code128
```
After `Succesfully generated the barcode.` message, the result can be seen in the file `result.bmp`.
