# AXI4_lite_slave

### **1. Project Overview**

This project implements a basic AXI4-Lite slave module in Verilog. The slave exposes an 8-word, 32-bit register file that an AXI master can write to and read from. This design is a synthesizable RTL model and is fully verified with a SystemVerilog testbench.

---

### **2. Directory Structure**

The project is organized into the following directories and files:

<img width="632" height="182" alt="image" src="https://github.com/user-attachments/assets/500ee4c8-cffa-4007-8754-0e755a0512e7" />

---

### **3. Design Details**

#### **3.1. Block Diagram**
The design consists of two main modules:
* `axi_slave.v`: This module handles the AXI4-Lite protocol handshake and address decoding logic.
* `register_file.v`: This module contains the sequential logic for storing data in an 8-word array of 32-bit registers.

The `axi_slave` module acts as a wrapper, connecting the AXI protocol signals to the simple read and write interfaces of the `register_file`.

#### **3.2. Register Map**
The slave is designed with a simple register map, with 8 registers at 4-byte intervals.

| Register Address | Register Name | Description | Access |
| :--------------- | :------------ | :---------- | :----- |
| `32'h00`         | REGISTER_0    | General-purpose register | Read/Write |
| `32'h04`         | REGISTER_1    | General-purpose register | Read/Write |
| `32'h08`         | REGISTER_2    | General-purpose register | Read/Write |
| `32'h0C`         | REGISTER_3    | General-purpose register | Read/Write |
| `32'h10`         | REGISTER_4    | General-purpose register | Read/Write |
| `32'h14`         | REGISTER_5    | General-purpose register | Read/Write |
| `32'h18`         | REGISTER_6    | General-purpose register | Read/Write |
| `32'h1C`         | REGISTER_7    | General-purpose register | Read/Write |

---

### **4. Verification**

The project includes a comprehensive testbench (`axi_slave_tb.sv`) to verify the functionality of the AXI slave. The testbench performs the following sequence of operations:

1.  Asserts a reset to initialize the DUT.
2.  Performs a write transaction to `REGISTER_0` with data `32'hdeadbeef`.
3.  Performs a read transaction from `REGISTER_0` and checks if the read data matches the written data.

---

### **5. Simulation**

The project is designed to be simulated using `Icarus Verilog` and the `vvp` interpreter. The provided `filelist.f` simplifies the compilation process.

1.  **Compilation**: Use `iverilog` with the provided file list.
    ```bash
    iverilog -o axi_sim -c filelist.f
    ```

2.  **Simulation**: Run the compiled executable.
    ```bash
    vvp axi_sim
    ```

The simulation will generate a `waves.vcd` file, which can be viewed with a waveform viewer like `GTKWave`.

---

### **6. Future Improvements**

This project serves as a strong foundation, but it can be expanded with more advanced features to demonstrate a deeper understanding of digital design and verification. Potential improvements include:

* **AXI Error Responses**: Implement and test `SLVERR` and `DECERR` responses for unsupported transactions (e.g., writes to read-only registers, or access to invalid addresses).
* **`wstrb` Support**: Implement byte-level writes using the `wstrb` signal, as this is a key part of the AXI4-Lite protocol.
* **Enhanced Testbench**: Implement more advanced test cases using SystemVerilog features like constrained random verification (CRV) and SystemVerilog Assertions (SVA) to ensure complete protocol compliance and corner-case handling.

Enhanced Testbench: Implement more advanced test cases using SystemVerilog features like constrained random verification (CRV) and SystemVerilog Assertions (SVA) to ensure complete protocol compliance and corner-case handling.
