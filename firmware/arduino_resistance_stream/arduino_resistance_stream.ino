// stream data from 16 channels 

unsigned long globalTime;
byte controlPins[] = {
  //A3 A2 A1 A0 EN On Switch
  //X1 X1 X1 X1 0 None
  B00001000,
  B00011000,
  B00101000,
  B00111000,
  B01001000,
  B01011000,
  B01101000,
  B01111000,
  B10001000,
  B10011000,
  B10101000, 
  B10111000, 
  B11001000, 
  B11011000, 
  B11101000, 
  B11111000  }; 
 
// store adc values here                 
float muxValues[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,};
float muxValues1[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,};
 
void setup()
{
  Serial.begin(9600);
  pinMode(45, OUTPUT); // A3
  pinMode(47, OUTPUT); // A2
  pinMode(49, OUTPUT); // A1
  pinMode(51, OUTPUT); // A0
  pinMode(53, OUTPUT); // EN
  
}
 
void displayData()
// dumps captured data from array to serial monitor
{
  
  for (int i = 0; i < 16; i++)
  {
    Serial.print(globalTime); // time
    Serial.print(' ');
    Serial.print(i); // pixelID 
    Serial.print(' '); 
    Serial.print(muxValues[i]); // adc value
    Serial.print(' '); 
    Serial.println(muxValues1[i]); // adc value
  }
  //Serial.println("========================");  
}
 
void loop()
{
  globalTime = int(millis() / 1000);
  
  for (int i = 0; i < 16; i++)
  {
    // shift by 3 bit and writes the last bit to the pin
    digitalWrite(53, controlPins[i]>>3 & B00000001);
    //Serial.print(controlPins[i]>>3 & B00000001);
    digitalWrite(51, controlPins[i]>>4 & B00000001);
    //Serial.print(controlPins[i]>>4 & B00000001);
    digitalWrite(49, controlPins[i]>>5 & B00000001);
    //Serial.print(controlPins[i]>>5 & B00000001);
    digitalWrite(47, controlPins[i]>>6 & B00000001);
    //Serial.print(controlPins[i]>>6 & B00000001);
    digitalWrite(46, controlPins[i]>>7 & B00000001);
    //Serial.println(controlPins[i]>>7 & B00000001);
    
    muxValues[i]=3.3*(analogRead(0)/1024.0); // read the vlaue on that pin and store in array
    muxValues1[i]=3.3*(analogRead(1)/1024.0); // read the vlaue on that pin and store in array

    delay(100);
  }
 
  // display captured data
  displayData();
  delay(2000); 
}
