# Dual-Clock Asynchronous CDC FIFO (`fifo_1r1w_cdc`)

A parameterized, dual-clock asynchronous First-In, First-Out (FIFO) buffer written in **SystemVerilog** for reliable data transfer across independent write and read clock domains (`wclk_i` and `rclk_i`) with `valid`/`ready` flow control.

---

## Repository Structure

```text
CDC-FIFO/
├── RTL/
│   └── fifo_1r1w_cdc.sv    # Parameterized dual-clock Gray-code CDC FIFO
├── LICENSE
└── README.md
```

---

## Architecture Overview

* **Gray-Code Pointer Synchronization:** Converts binary write and read pointers into Gray code prior to crossing clock domains so only a single bit transitions per clock cycle, preventing multi-bit sampling skew across asynchronous boundaries.
* **Two-Stage Flip-Flop Synchronizers:** Passes Gray-coded read pointers into the `wclk_i` domain and Gray-coded write pointers into the `rclk_i` domain through 2-FF synchronizer chains to mitigate metastability.
* **Conservative Full & Empty Flag Generation:** Compares synchronized Gray-code pointers against local pointers to drive `wready_o` (not full) and `rvalid_o` (not empty) without risking data corruption, overflow, or underflow.
* **Hardware Verification Context:** Designed and verified on an **iCEBreaker v1.1a (`iCE40UP5K`)** FPGA (including `width_p = 48` AXI-Stream / UART-AXI bridge integration at 12 MHz / 115,200 baud).

---

## External Primitives Disclosure

To keep this repository focused strictly on original RTL, course-provided library primitives and transport wrappers (`uart_axi`, `uart_axis`, and board `.pcf` constraints) are omitted. Instantiating or synthesizing `RTL/fifo_1r1w_cdc.sv` in a larger design requires compatible definitions for any underlying standard storage or flip-flop primitives (such as `dff` or `ram_1r1w_async` / `ram_1r1w_sync`).

---

## Acknowledgments
* **Toolchain & Curriculum Context:** Built within a modular synchronous/asynchronous FPGA design workflow inspired by the open-source iCEBreaker curriculum developed by **Professor Dustin Richmond** (UCSC Baskin School of Engineering).
