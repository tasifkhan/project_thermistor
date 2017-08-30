# project_thermistor
- Stream, visualize, and save 16 channel thermistor data using arduino due.
- Thermistor array is connected to the 32 pin .5 mm pitch FFC connector.
Those connections goes to the analog switch, and to the bridge circuit.
- Switch address connections

| MUX Pins| Arduino Pins |
| :------:|:------------:|
| EN      |53            |
| A0      |51            |
| A1      |49            |
| A2      |47            |
| A3      |45            |

## notes
- 2017_08_27 checked both hardware and firmware, correctly outputting resistance values.
