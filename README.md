# Elevator Controller – Verilog RTL

## Overview

This project implements a **basic elevator controller** using **Verilog RTL**.  
The design is based on a **Finite State Machine (FSM)** and models the essential behavior of a real elevator system.

The project is developed for **learning and demonstrating RTL design and verification skills**.

---

## Design Approach

The elevator controller is implemented as a Moore-type finite state machine (FSM).
Each state represents a distinct elevator behavior, including idle, upward movement,
downward movement, and door open.

Floor requests are stored using a bitmask representation, allowing the controller
to efficiently scan for pending requests above and below the current floor and
determine the next movement direction.

---

## FSM States

| State        | Description |
|--------------|------------|
| IDLE         | Elevator is stationary and waits for new requests |
| MOVE_UP      | Elevator moves upward one floor per clock cycle |
| MOVE_DOWN    | Elevator moves downward one floor per clock cycle |
| DOOR_OPEN    | Elevator door remains open for a fixed number of cycles |

---

## Features

- FSM-based elevator control
- Configurable number of floors
- Floor requests represented as a bitmask for efficient request scanning
- Upward and downward movement control
- One-floor-per-cycle movement
- Door open control with fixed open time

---

## Request Handling and Priority Logic

When multiple floor requests are active, the controller prioritizes requests based
on their relative position to the current floor. Pending requests above or below
the current position are detected by scanning the request bitmask, ensuring deterministic movement behavior and avoiding unnecessary direction changes.

---

## Verification Strategy

The design is verified using a **custom Verilog testbench**.  
Simulation covers the following scenarios:

- Request at the current floor
- Upward movement
- Downward movement
- Multiple simultaneous floor requests

Detailed waveform analysis and functional verification results are provided in:

📄 **[`docs/Report.md`](docs/Report.md)**

(The synthesized schematic is included for reference only.)

---

## Limitations and Future Improvements

- The current design supports a single elevator car.
- Request scheduling is based on static priority without optimization.
- Future improvements may include dynamic scheduling algorithms,
  emergency handling, and support for multiple elevator systems.





