# SPI Communication Protocol Design

## Block Diagram
![Diagram](https://github.com/Moaz-Helmy/SPI-Communication-Protocol/blob/master/SPI%20.jpg)
---
  In this Project, the commonly known serial communication protocol which is the Serial Peripheral Interface (SPI) has been designed and implemented using verilog HDL.

  In order to facilitate the design process, the project was divided into the three major modules as listed below.
  1. Counter
   > - The counter role was to count the number of data bits received at the MOSI pin, so that the SPI Slave knows when to transfer the data to the Data Memory.

2. Data Memory
>- The memory receives 10 bits from the SPI Slave per operation. The 2 MSBs represents a special command, that the Memory translates and upon which makes a decision to either save the received data as a read/write address or to load/store the data from/at the saved address.

3. The SPI Slave
> - The SPI Slave is the outer interface to the outside world. It's responsible to deserialize the data received at the MOSI pin, and to serialize those read from the Data Memory and send them via the MISO pin.

---
## Testing the Top Module

- After finishing the RTLs of the three main modules, four major tests were conducted against the top module to test its functionality. These 4 tests are receiving data at the MOSI pin, storing data in Data Memory, reading data from the data memory, and sending the read data via the MISO pin.

The following input sequences were fed into the top module at the MOSI except the LSB and MSB, as they were fed into the SS pin.
```
1000000001000  --> Prompting the memory to save 00000010 as a write address 
1011111111100  --> Storing FF in the saved write address
1100000001010  --> Prompting the memory to save 00000010 as a read address
0110000101010  --> Read the data from the specified read address and send it through the MISO pin
```
- The results of these tests were observed carefully on the generated waveforms, and the tests were a success as the value FF was read successfully at the MISO pin as shown in the following waveform.

![Waveform](https://github.com/Moaz-Helmy/SPI-Communication-Protocol/blob/master/Waveform/Waveform.JPG)


