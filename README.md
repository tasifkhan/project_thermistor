## thermistor_array_driver

- Stream, visualize, and save 16 channel thermistor data using arduino due.
- The thermistor array is connected to the 32 pin .5 mm pitch FFC connector. Then, those connections goes to an analog switch, and to a bridge circuit.
- Switch address connections

| MUX Pins| Arduino Pins |
| :------:|:------------:|
| EN      |53            |
| A0      |51            |
| A1      |49            |
| A2      |47            |
| A3      |45            |

### directory setup

- /desktop_app/ ipython programs   and temperature and beta plot
  - 'temperature_mapping.ipynb' for real time temperature mapping
  - 'thermistor_array_plot_v1.ipynb' for thermistor temp and beta plots
- /desktop_app/data all raw data are saved here
- /firmware/ firmware for data streaming *use the latest version*
- /hardware/ hardware files

### notes

- 2017_09_13 added ipython real time temperature mapping and code for thermistor temp and beta plots
- 2017_08_27 checked both hardware and firmware, correctly outputting resistance values.
