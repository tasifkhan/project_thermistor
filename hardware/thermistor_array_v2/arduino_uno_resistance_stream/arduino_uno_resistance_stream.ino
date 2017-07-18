// 2016_05_03 reading out two channels of resistance

unsigned long time;

int analogVal = 0;
float analogVol;
int T0 = 55;
double Rt;

int beta = 4000;
int Vb = 5; 
int R = 660000;

const int selectPins[5] = {53, 51, 49, 47, 45}; // EN~53, A0~51, A1~49 A2~47 A3~45
const int zOutput = 6; // Connect common (Z) to 6 (PWM-capable)
double readings[16];


void setup() 
{
  Serial.begin(9600);
  // Set up the select pins, as outputs
  for (int i=0; i<3; i++)
  {
    pinMode(selectPins[i], OUTPUT);
    digitalWrite(selectPins[i], LOW);
  }
  pinMode(zOutput, OUTPUT); // Set up Z as an output
}

 
void loop() 
{

   for (int pin=0; pin<=15; pin++)
  {
    selectMuxPin(pin); // selects a pin    
    analogVal = analogRead(A1);
    analogVol = 4.95*(analogVal/1023.0);
    Rt = analogVol * R / (Vb - analogVol);
    double Tinverse = log(Rt/R)/beta + 1/T0;
    double T = 1/Tinverse;
    readings[pin] = T;

//    time = millis();
//    Serial.print(time);
//    Serial.print("\t"); 
    Serial.println(readings[pin], DEC);
  }    
}

void selectMuxPin(byte pin)
{
  if (pin > 15) return; // Exit if pin is out of scope
  for (int i=1; i<4; i++)
  {
    if (pin & (1<<i))
      digitalWrite(selectPins[i], HIGH);
    else
      digitalWrite(selectPins[i], LOW);
  }  }


  
 
