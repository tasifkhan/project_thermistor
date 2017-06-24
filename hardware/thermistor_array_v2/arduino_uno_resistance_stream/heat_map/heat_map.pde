import cc.arduino.*;
import org.firmata.*;
import apsync.*;
import processing.serial.*;



float[][] interp_array;
Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port
int lf = 10;
 
void setup() {
  String portName = Serial.list()[3]; 
  myPort = new Serial(this, portName, 9600);
  size(400, 400);
  interp_array = new float[400][400];
  makeArray();
  applyColor();
}
 
// Fill array with Perlin noise (smooth random) values
void makeArray() {
  for (int r = 0; r < height; r++) {
    for (int c = 0; c < width; c++) {
      if ((r == 50 || r == 150 || r == 250 || r == 350) && (c == 50 || c == 150 || c == 250 || c == 350)) {
        String data = myPort.readStringUntil(lf);
        interp_array[c][r] = Float.parseFloat(data);
      }
      // Range is 24.8 - 30.8
      interp_array[c][r] = 24.8 + 6.0 * noise(r * 0.02, c * 0.02);
    }
  }
}
 
void applyColor() {  // Generate the heat map
  pushStyle(); // Save current drawing style
  // Set drawing mode to HSB instead of RGB
  colorMode(HSB, 1, 1, 1);
  loadPixels();
  int p = 0;
  for (int r = 0; r < height; r++) {
    for (int c = 0; c < width; c++) {
      // Get the heat map value 
      float value = interp_array[c][r];
      // Constrain value to acceptable range.
      value = constrain(value, 25, 30);
      // Map the value to the hue
      // 0.2 blue
      // 1.0 red
      value = map(value, 25, 30, 0.2, 1.0);
      pixels[p++] = color(value, 0.9, 1);
    }
  }
  updatePixels();
  popStyle(); // Restore original drawing style
}