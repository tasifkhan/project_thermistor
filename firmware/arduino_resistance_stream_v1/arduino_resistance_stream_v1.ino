// stream data from 16 channels 
// time pixel id resistance0 ref_resistance [MOhm]
// 2017_08_29 working version

unsigned long globalTime;
byte controlPins[] = {
  //A3 A2 A1 A0 EN 
  //45 47 49 51 53
  B00000001,
  B00000011,
  B00000101,
  B00000111,
  B00001001,
  B00001011,
  B00001101,
  B00001111,
  B00010001,
  B00010011,
  B00010101, 
  B00010111, 
  B00011001, 
  B00011011, 
  B00011101, 
  B00011111  }; 
 
// store adc values here   
float v0[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // voltage reading 
float v1[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // voltage reading               
int muxValues[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // resistance 
float muxValues1[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}; // resistance
float dummy[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,};
char printTime[10];

String convert(int data) {
  float v0=3.3*(data/1024.0); // v0
  float res =((.964*v0)/(3.3)) / (1-(v0/3.3)); // (r0*(v0/3.3))/(1-(v0/3.3)) = rx
  return String(res, 4);
}

void setup()
{
  Serial.begin(115200);
  pinMode(45, OUTPUT); // A3
  pinMode(47, OUTPUT); // A2
  pinMode(49, OUTPUT); // A1
  pinMode(51, OUTPUT); // A0
  pinMode(53, OUTPUT); // EN
  pinMode(A0, INPUT);
  pinMode(A1, INPUT);
  
}
 
void displayData()
// dumps captured data from array to serial monitor
{
  
  for (int i = 0; i < 16; i++)
  {
    globalTime = int(millis() / 1000);
    char printTime[10];
    sprintf(printTime, "%06d", globalTime);
    Serial.print(printTime);
    Serial.print(' ');
    //Serial.print(i); // pixelID 
    Serial.print(' '); 
    Serial.print(convert(muxValues[i])); // resistance
    //Serial.print(' '); 
    //Serial.print(muxValues1[i]); // resistance
  }
  Serial.println('\r');  
}
 
void loop()
{
  
  
  for (int i = 0; i < 16; i++) // reading one channel at a time
  {
    // shift by 1 bit and writes the last bit to the pin
    digitalWrite(53, controlPins[i]>>0 & B00000001); //EN
    //Serial.print(controlPins[i]>>0 & B00000001);
    digitalWrite(51, controlPins[i]>>1 & B00000001); //A0
    //Serial.print(controlPins[i]>>1 & B00000001);
    digitalWrite(49, controlPins[i]>>2 & B00000001); //A1
    //Serial.print(controlPins[i]>>2 & B00000001);
    digitalWrite(47, controlPins[i]>>3 & B00000001); //A2
    //Serial.print(controlPins[i]>>3 & B00000001);
    digitalWrite(45, controlPins[i]>>4 & B00000001); //A3
    //Serial.println(controlPins[i]>>4 & B00000001);

    // dummy reads otherwise the adc goes all over the places - v0
    for (int j = 0; j < 5; j++){
      dummy[j]= analogRead(A0);
      delay(10);
    }
    //v0[i]=3.3*(analogRead(A0)/1024.0); // v0
    //muxValues[i]=((.964*v0[i])/(3.3)) / (1-(v0[i]/3.3)); // (r0*(v0/3.3))/(1-(v0/3.3)) = rx
    muxValues[i] = analogRead(A0);
    delay(10);

    // dummy reads otherwise the adc goes all over the places - v1
    for (int j = 0; j < 5; j++){
      dummy[j]=analogRead(A1);
      delay(10);
    }
    v1[i]=3.3*(analogRead(A1)/1024.0); // read the vlaue on that pin and store in array
    muxValues1[i]=((.985*v1[i])/(3.3)) / (1-(v1[i]/3.3));
    delay(50);
  }
 
  // display captured data
  
  displayData();
  delay(10); 
}
