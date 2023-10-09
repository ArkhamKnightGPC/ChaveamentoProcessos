# Process Switching
This project is a bare metal application implementing process switching in an ARM based processor emulator.

The goal is to use the timer interrupt to switch between two tasks. The first one, taskA that continuously prints "1" and taskB prints "2".

![Resultado obtido](/QEMUprintscreen.png)

## Implementation ***irq.s***

Firstly, we load the interrupt vector. At reset, we initialise the interrupt controller and the timer.

The timer's interrupt routine must switch between tasks; to do this, it must save the state of the current process in a data structure that we'll call the process table. When the interrupt routine exits, the registers of the other process must be retrieved.

Course website: [https://www2.pcs.usp.br/~jkinoshi](https://www2.pcs.usp.br/~jkinoshi/2022/labmicro-22.html#org6766b53)
