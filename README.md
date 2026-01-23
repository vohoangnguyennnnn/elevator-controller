# Elevator Controller – Verilog RTL

## Overview

This project implements a **basic elevator controller** using **Verilog RTL**.  
The design is based on a **Finite State Machine (FSM)** and models the essential behavior of a real elevator system.

The project is developed for **learning and demonstrating RTL design and verification skills**.

---

## Features

- FSM-based elevator control
- Configurable number of floors
- Floor requests represented as a bitmask
- Upward and downward movement control
- One-floor-per-cycle movement
- Door open control with fixed open time

---

## Simulation & Verification

The design is verified using a **custom Verilog testbench**.  
Simulation covers the following scenarios:

- Request at the current floor
- Upward movement
- Downward movement
- Multiple simultaneous floor requests

Detailed RTL schematic and waveform results are provided in:

📄 **[`docs/Report.md`](docs/Report.md)**




