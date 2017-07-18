import controlP5.*;
import processing.serial.*;
import java.util.Map;
import java.io.*;
import java.util.Arrays;
import java.util.Collections;
// adding for the rolling plot

import org.gwoptics.graphics.graph2D.Graph2D;
import org.gwoptics.graphics.graph2D.traces.ILine2DEquation;
import org.gwoptics.graphics.graph2D.traces.RollingLine2DTrace;

class red_plot_data implements ILine2DEquation{
  public double computePoint(double x,int pos) {
    return Rdata;
  }    
}

class ired_plot_data implements ILine2DEquation{
  public double computePoint(double x,int pos) {
    return IRdata;
  }    
}

class red_amb_plot_data implements ILine2DEquation{
  public double computePoint(double x,int pos) {
    return Ramb;
  }    
}

class ired_amb_plot_data implements ILine2DEquation{
  public double computePoint(double x,int pos) {
    return IRamb;
  }    
}

RollingLine2DTrace r,ir,ra,ira;
Graph2D g, h;


/////////////////////////////////////////// checked ///////////////////////////////////////////

ControlP5 controlP5;
// serial port
DropdownList serialPortsList;
final int BAUD_RATE = 115200;
String[] portNames = Serial.list();


// serial port end
PImage map_red;
PImage map_ired;
PImage map_so2;
//Serial s = new Serial(this, "/dev/tty.usbmodem1411", 115200);
Serial s;// = new Serial(this, "COM8", 115200);

controlP5.Button hop;
controlP5.Button send;
controlP5.Button save;
controlP5.Button stop;
controlP5.Toggle t1;
controlP5.Toggle t2;
controlP5.Toggle t3;
controlP5.Toggle t4;
controlP5.Slider i1;
controlP5.Slider i2;
controlP5.Slider r1;
controlP5.Slider r2;
controlP5.Slider c1;
controlP5.Slider c2;
controlP5.Slider g1;
controlP5.Slider g2;
controlP5.Slider ir1;
controlP5.Slider ir2;
controlP5.Slider dpf1;
controlP5.Slider dpf2;
controlP5.Slider d;
controlP5.Textlabel text;
controlP5.Textlabel text2;

/////////////////////////////////////////// checked ///////////////////////////////////////////
// mapping



// graphic variables
int weight = 2;
int red = color(228, 26, 28);
int green = color(0x00, 0x64, 0x00);
int purple = color(0x66, 0x33, 0x99);
int blue = color(55, 126, 184);
int grey = color(234, 234, 234);
int gold = color(255,198,51);
int record_length = 1000;

int x_plot_start = 250;

// Internal calculation variables
HashMap<Integer,Integer> resMap = new HashMap<Integer,Integer>();
HashMap<Integer,Integer> capMap = new HashMap<Integer,Integer>();
HashMap<Float,Integer> gainMap = new HashMap<Float,Integer>();
float resList[] = new float[]{500, 250, 100, 50, 25, 10};
float capList[] = new float[]{5, 10, 20, 25, 30, 35, 45, 50, 55, 60, 70, 75, 80, 85, 95, 100, 155, 160, 170, 175, 180, 185, 195, 200, 205, 210, 220, 225, 230, 235, 245, 250};
float gainList[] = new float[]{9.5, 0, 3.5, 12, 6};
float curList[] = new float[84];

boolean SINGLE = true;
boolean R2G = false;
boolean IR2G = false;
boolean eqGain = true;
boolean eqCur = true;
boolean taskLock = false;

float cur1 = 5;//0
float cur2 = 5;//0
float resR = 100;//500
float resIR = 100;//500
float capR = 5;//
float capIR = 5;//
float RGain = 0;//
float IRGain = 0;//

// data storage variables
float Rdata = 0;
float IRdata = 0;
float Ramb = 0;
float IRamb = 0;
int timestamp = 0;
int pixelID = 0;
int[] timestampArray = new int[record_length];
int[] pixelIDArray = new int[record_length];
float[] RArray = new float[record_length];
float[] IRArray = new float[record_length];
float[] ambRArray = new float[record_length];
float[] ambIRArray = new float[record_length];

float[] redPixel = new float[9];
float[] iredPixel = new float[9];
int[] redCount = new int[9];
int[] iredCount = new int[9];
boolean stopgraph = false;
boolean savedata = false;

/////////////////////////////////////////// checked ///////////////////////////////////////////

void setup() {
  size(1700,1000);

  map_red = loadImage("blank.png");
  map_ired = loadImage("blank.png");
  map_so2 = loadImage("blank.png");
  smooth();
  PFont pfont = createFont("Arial",16,true);
  ControlFont font = new ControlFont(pfont,16);
  controlP5 = new ControlP5(this);
  
  serialPortsList = controlP5.addDropdownList("serial ports").setPosition(800, 10).setWidth(200);
  for(int i = 0 ; i < portNames.length; i++) serialPortsList.addItem(portNames[i], i);

/////////////////////////////////////////// checked ///////////////////////////////////////////

  // description : a button executes after release
  // parameters  : name, value(float), x, y, width, height
  
  hop = controlP5.addButton("Single/Array",0,10,10,150,40);
  hop.getCaptionLabel()
     .setFont(font)
     .toUpperCase(true)
     .setSize(14);
  send = controlP5.addButton("send",0,10,540,150,40);
  send.getCaptionLabel()
      .setFont(font)
      .toUpperCase(true)
      .setSize(14);
  stop = controlP5.addButton("stop",0,10,610,150,40);
  stop.getCaptionLabel()
      .setFont(font)
      .toUpperCase(true)
      .setSize(14);
  save = controlP5.addButton("save",0,10,680,150,40);
  save.getCaptionLabel()
      .setFont(font)
      .toUpperCase(true)
      .setSize(14);
/////////////////////////////////////////// checked ///////////////////////////////////////////

  // description : a toggle has two states
  // parameters  : name, value(boolean), x, y, width, height
  t1 = controlP5.addToggle("Enable Red Gain 2",false,10,260,10,10);
  t1.getCaptionLabel()
    .setFont(font)
    .setColor(0)
    .toUpperCase(false)
    .setSize(12);
  t1.getCaptionLabel().getStyle().marginLeft = 20;
  t1.getCaptionLabel().getStyle().marginTop = -15;
  t2 = controlP5.addToggle("Same Gain 1",true,10,180,10,10);
  t2.getCaptionLabel()
    .setFont(font)
    .setColor(0)
    .toUpperCase(false)
    .setSize(16);
  t2.getCaptionLabel().getStyle().marginLeft = 20;
  t2.getCaptionLabel().getStyle().marginTop = -20;
  t3 = controlP5.addToggle("Enable IRed Gain 2",false,10,380,10,10);
  t3.getCaptionLabel()
    .setFont(font)
    .setColor(0)
    .toUpperCase(false)
    .setSize(12);
  t3.getCaptionLabel().getStyle().marginLeft = 20;
  t3.getCaptionLabel().getStyle().marginTop = -15;
  t3.lock();
  t4 = controlP5.addToggle("Same Current",true,10,60,10,10);
  t4.getCaptionLabel()
    .setFont(font)
    .setColor(0)
    .toUpperCase(false)
    .setSize(16);
  t4.getCaptionLabel().getStyle().marginLeft = 20;
  t4.getCaptionLabel().getStyle().marginTop = -20;

  // description : a slider is either used horizontally or vertically.
  //               width is bigger, you get a horizontal slider
  //               height is bigger, you get a vertical slider.  
  // parameters  : name, minimum, maximum, default value (float), x, y, width, height
  
  i1 = controlP5.addSlider("Red Current",0,24.9,6,10,80,150,10);
  i1.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  i1.getCaptionLabel().getStyle().marginLeft = -150;
  i1.getCaptionLabel().getStyle().marginTop = 10;
  i2 = controlP5.addSlider("IRed Current",0,24.9,6,10,120,150,10);
  i2.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  i2.getCaptionLabel().getStyle().marginLeft = -150;
  i2.getCaptionLabel().getStyle().marginTop = 10;
  i2.lock();
  r1 = controlP5.addSlider("Red Rf",500,10,0,10,200,150,10);
  r1.setValue(500);
  r1.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  r1.getCaptionLabel().getStyle().marginLeft = -150;
  r1.getCaptionLabel().getStyle().marginTop = 10;
  c1 = controlP5.addSlider("Red Cf",5,250,0,10,240,150,10);
  c1.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  c1.getCaptionLabel().getStyle().marginLeft = -150;
  c1.getCaptionLabel().getStyle().marginTop = 10;
  g1 = controlP5.addSlider("Red Gain 2",0,12,0,10,280,150,10);
  g1.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  g1.getCaptionLabel().getStyle().marginLeft = -150;
  g1.getCaptionLabel().getStyle().marginTop = 10;
  g1.lock();
  r2 = controlP5.addSlider("IRed Rf",500,10,0,10,320,150,10);
  r2.setValue(500);
  r2.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  r2.getCaptionLabel().getStyle().marginLeft = -150;
  r2.getCaptionLabel().getStyle().marginTop = 10;
  r2.lock();
  c2 = controlP5.addSlider("IRed Cf",5,250,0,10,360,150,10);
  c2.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  c2.getCaptionLabel().getStyle().marginLeft = -150;
  c2.getCaptionLabel().getStyle().marginTop = 10;
  c2.lock();
  g2 = controlP5.addSlider("IRed Gain 2",0,12,0,10,400,150,10);
  g2.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  g2.getCaptionLabel().getStyle().marginLeft = -150;
  g2.getCaptionLabel().getStyle().marginTop = 10;
  g2.lock();
  
  ir1 = controlP5.addSlider("IR YMAX",0.0,1.2,0,280,380,150,10);
  ir1.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  ir1.getCaptionLabel().getStyle().marginLeft = -150;
  ir1.getCaptionLabel().getStyle().marginTop = 10;
  ir1.setValue(1.2);
  
  ir2 = controlP5.addSlider("R YMAX",0.0,1.2,0,280,840,150,10);
  ir2.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  ir2.getCaptionLabel().getStyle().marginLeft = -150;
  ir2.getCaptionLabel().getStyle().marginTop = 10;
  ir2.setValue(1.2);
  
  dpf1 = controlP5.addSlider("DPF Red",0.0,25.0,7.0,10,760,150,10);
  dpf1.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  dpf1.getCaptionLabel().getStyle().marginLeft = -150;
  dpf1.getCaptionLabel().getStyle().marginTop = 10;
  dpf1.setValue(7.0);
  
  dpf2 = controlP5.addSlider("DPF IRed",0.0,25.0,14.0,10,800,150,10);
  dpf2.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  dpf2.getCaptionLabel().getStyle().marginLeft = -150;
  dpf2.getCaptionLabel().getStyle().marginTop = 10;
  dpf2.setValue(14.0);
  
  d = controlP5.addSlider("OLED-OPD Spacing",0.0,1.0,0.5,10,840,150,10);
  d.getCaptionLabel()
    .setFont(font)
    .toUpperCase(true)
    .setColor(0)
    .setSize(16);
  d.getCaptionLabel().getStyle().marginLeft = -150;
  d.getCaptionLabel().getStyle().marginTop = 10;
  d.setValue(0.5);
  


  text = controlP5.addTextlabel("values")
                  .setPosition(10,460)
                  .setSize(10, 10)
                  .setColor(0)
                  .setFont(font);
  text.setValue("Values:");
  
  text2 = controlP5.addTextlabel("values2")
                  .setPosition(10,900)
                  .setSize(10, 10)
                  .setColor(0)
                  .setFont(font);
  text2.setValue("Raw Data:");
  
  for (int i = 0; i < 84; i++) {
    curList[i] = i * 0.3;
  }
  int base[] = new int[]{150, 50, 25, 15, 5};
  for (int i = 0; i < 32; i++) {
    int value = (i&16)/16*base[0]+(i&8)/8*base[1]+(i&4)/4*base[2]+(i&2)/2*base[3]+(i&1)*base[4]+5;
    capMap.put(value, i);
  }
  resMap.put(500, 0);resMap.put(250, 1);resMap.put(100, 2);resMap.put(50, 3);resMap.put(25, 4);resMap.put(10, 5);
  gainMap.put(0.0, 0);gainMap.put(3.5, 1);gainMap.put(6.0, 2);gainMap.put(9.5, 3);gainMap.put(12.0, 4);
  for (int i = 0; i < RArray.length; i++) {
    timestampArray[i] = 0;
    pixelIDArray[i] = 0;
    RArray[i] = 0;
    IRArray[i] = 0;
    ambRArray[i] = 0;
    ambIRArray[i] = 0;
  }
  
  r  = new RollingLine2DTrace(new red_plot_data() ,100,0.4f);
  r.setTraceColour(228, 26, 28);
  r.setLineWidth(4);
  
  ra  = new RollingLine2DTrace(new red_amb_plot_data() ,100,0.4f);
  ra.setTraceColour(255,127,0);
  ra.setLineWidth(4);
  
  ir  = new RollingLine2DTrace(new ired_plot_data() ,100,0.4f);
  ir.setTraceColour(77, 175, 74);
  ir.setLineWidth(4);
  
  ira  = new RollingLine2DTrace(new ired_amb_plot_data() ,100,0.4f);
  ira.setTraceColour(24, 24, 24);
  ira.setLineWidth(4);
   
  g = new Graph2D(this, 1000, 400, false);
  
  g.setYAxisMax(ir1.getValue());
  //g.addTrace(r);
  //g.addTrace(ra);
  g.addTrace(ir);
  g.addTrace(ira);
  g.position.y = 20;
  g.position.x = x_plot_start;
  g.setYAxisTickSpacing(0.1);
  g.setYAxisMax(1.2);
  g.setXAxisTickSpacing(20);
  g.setXAxisMax(150f);//150
  g.setYAxisTickFont("Arial", 24, true);
  g.setXAxisTickFont("Arial", 24, true);
  g.setYAxisLabel("Intensity (V)");
  g.setXAxisLabel("Time");
  g.setYAxisLabelFont("Arial", 24, true);
  g.setXAxisLabelFont("Arial", 24, true);
  
  h = new Graph2D(this, 1000, 400, false);
  // h.setYAxisMax(ir1.getValue());
  h.addTrace(r);
  h.addTrace(ra);

  h.position.y = 480;
  h.position.x = x_plot_start;
  h.setYAxisTickSpacing(0.1);
  h.setYAxisMax(1.2);
  h.setXAxisTickSpacing(20);
  h.setXAxisMax(150f);//150
  h.setYAxisTickFont("Arial", 24, true);
  h.setXAxisTickFont("Arial", 24, true);
  h.setYAxisLabel("Intensity (V)");
  h.setXAxisLabel("Time");
  h.setYAxisLabelFont("Arial", 24, true);
  h.setXAxisLabelFont("Arial", 24, true);

  
}

float getNearest(float[] list, float target) {
  float distance = 65535;
  float nearest = 0;
  for (int i = 0; i < list.length; i++) {
    if (abs(target - list[i]) < distance) {
      distance = abs(target - list[i]);
      nearest = list[i];
    }
  }
  return nearest;
}

void draw() {
  background(0xe6e6e6);//0xeee8aa, 0x6d6d6d grey
  controlP5.show();
  controlP5.draw();
  stroke(0,50,75);
  
  controlP5 = new ControlP5(this);
  PFont p = createFont("Georgia",18); 
  controlP5.setControlFont(p,18);

  
  stroke(0,0,0);
  strokeWeight(2);  
  noFill();
  image(map_red, 1280, 20, 400, 300);
  rect(1280, 20, 400, 300);
  textSize(20);
  //fill(0,50,75);
  fill(0,0,0);
  text("Reflected Intensity - Red", 1300, 40);
  
  image(map_ired, 1280, 330, 400, 300);
  noFill();
  rect(1280, 330, 400, 300);
  fill(0,0,0);
  text("Reflected Intensity - Infrared", 1300, 350);
  
  image(map_so2, 1280, 640, 400, 300);
  noFill();
  rect(1280, 640, 400, 300);
  fill(0,0,0);
  text("Oxygen Saturation", 1300, 660);
  
  displayGraph();
  
  g.draw();
  h.draw();
    
  fill(77, 175, 74);
  rect(960, 320, 20, 20);
  textSize(20);
  //fill(0,50,75);
  text("Infrared", 1000, 340);
  
  fill(24, 24, 24);
  rect(960, 360, 20, 20);
  textSize(20);
  //fill(0,50,75);
  text("Infrared Ambient", 1000, 380);
  
  fill(228, 26, 28);
  rect(960, 780, 20, 20);
  textSize(20);
  //fill(0,50,75);
  text("Red", 1000, 800);
  
  fill(255,127,0);
  rect(960, 820, 20, 20);
  textSize(20);
  //fill(0,50,75);
  text("Red Ambient", 1000, 840);

}

/////////////////////////////////////////// checked ///////////////////////////////////////////





String filename = "data.txt";

void displayGraph() {
  noFill();
  stroke(0,50,90);
  strokeWeight(weight);
  
  // create a folder with date, and save file with time
  
  String[] folderS = new String[3]; 
  folderS[0] = str(year());   // 2003, 2004, 2005, etc.
  folderS[1] = str(month());  // Values from 1 - 12
  folderS[2] = str(day());    // Values from 1 - 31

  String folderName = join(folderS, "_"); 

  String[] fileS = new String[3]; 
  fileS[0] = str(hour());   // 2003, 2004, 2005, etc.
  fileS[1] = str(minute());  // Values from 1 - 12
  fileS[2] = str(second());    // Values from 1 - 31
  
  String fileName = join(fileS, "_"); 

  String fileSave = "data/" + folderName +"/"+fileName+".txt";
  //String fileSavePixels = "data/" + folderName +"/"+fileName+"_pixels.txt";
  
/////////////////////////////////////////// checked ///////////////////////////////////////////  
  
  
  
  if (savedata) {
    savedata = false;
    String[] lines = new String[record_length];
    for (int i = 0; i < record_length; i++)  {
      lines[i] = timestampArray[i] + "," + pixelIDArray[i] + "," + RArray[i] + "," + ambRArray[i] + "," + IRArray[i]+ "," + ambIRArray[i];
    }  
    saveStrings(fileSave, lines);
//    plotSurfaceMap ();
//    String[] linesPixels = new String[9];
//    for (int i = 0; i < 9; i++)  {
//      linesPixels[i] = redCount[i] + "," + redPixel[i] + "," + iredCount[i] + "," + iredPixel[i];
//    }  
//    saveStrings(fileSavePixels, linesPixels);
    //if (SINGLE = false)  {
      String cwd = sketchPath("");//"C:\\Users\\tasif\\Dropbox\\project_reflection_oximeter\\mapping\\processing\\pulse_ox_mapping_v1\\";
      //String command = "cmd /c start python " +cwd +"oximeter_surface_mapping.py " +cwd+"data\\" + folderName +"\\"+fileName+".txt";
      String command = "cmd /c start python " +cwd +"oximeter_surface_mapping.py " +cwd+"data\\" + folderName +"\\"+fileName+".txt " +dpf1.getValue() +" " +dpf2.getValue() +" " +d.getValue();
      //String pythonCommand = "python oximeter_surface_mapping.py data/" + folderName +"/"+fileName+".txt";
      println(command); 
    
    try{
  //String[]callAndArgs= {\"python\",\"oximeter_surface_mapping.py\",\"data/2016_4_1/1_6_2_full.txt\"};

    Process p = Runtime.getRuntime().exec(command);
  //Process p = Runtime.getRuntime().exec("cmd /c start C:\\Users\\tasif\\Dropbox\\project_reflection_oximeter\\mapping\\processing\\filename_test\\run.bat");
    p.waitFor();
    }catch( IOException ex ){
    //Validate the case the file can't be accesed (not enought permissions)

    }catch( InterruptedException ex ){
    //Validate the case the process is being stopped by some external situation     

    }
    
    try {
    Thread.sleep(4000);                 //1000 milliseconds is one second.
    } catch(InterruptedException ex) {
    Thread.currentThread().interrupt();
    }
    
    //}
    // adding the maps
    String red_img = folderName +"/"+fileName+"_red.png";//"data/" + 
    String ired_img = folderName +"/"+fileName+"_ired.png";
    String so2_img = folderName +"/"+fileName+"_so2.png";
    
    //map_red = loadImage(red_img);
    //image(map_red, 0, 0);
    //map_ired = loadImage(ired_img);
    //image(map_ired, 0, 0);
    //map_so2 = loadImage(so2_img);
    //image(map_so2, 1100, 10, 50, 50);
    
  }
  
    
    
  beginShape();
//  for (int i = 0; i < RArray.length - 1; i++) {
//    line(250+i,170-RArray[i]*2*500,250+(i+1),170-RArray[i+1]*2*500);
//    line(250+i,350-ambRArray[i]*2*500,250+(i+1),350-ambRArray[i+1]*2*500);
//    line(250+i,530-IRArray[i]*2*500,250+(i+1),530-IRArray[i+1]*2*500);
//    line(250+i,710-ambIRArray[i]*2*500,250+(i+1),710-ambIRArray[i+1]*2*500);
//  }
  endShape();
  if (stopgraph) {
    return;
  }
  for (int i = 0; i < RArray.length - 1; i++) {
    timestampArray[i] = timestampArray[i+1];
    pixelIDArray[i] = pixelIDArray[i+1];
    RArray[i] = RArray[i+1];
    IRArray[i] = IRArray[i+1];
    ambRArray[i] = ambRArray[i+1];
    ambIRArray[i] = ambIRArray[i+1];
  }
  timestampArray[timestampArray.length-1] = timestamp;
  pixelIDArray[pixelIDArray.length-1] = pixelID;
  RArray[RArray.length-1] = Rdata;
  IRArray[RArray.length-1] = IRdata;
  ambRArray[RArray.length-1] = Ramb;
  ambIRArray[RArray.length-1] = IRamb;
}

void sendCommand() {
  int ctrlVal = 65536 + (int)(cur1/0.3) + (int)(cur2/0.3) * 256;
  int gainVal1 = resMap.get((int)resR) + capMap.get((int)capR) * 8 + gainMap.get(RGain) * 256 + (R2G?1:0) * 16384;
  s.write(hex(ctrlVal));
  s.write(" ");
  s.write(hex(gainVal1));
  if (!eqGain) {
    int gainVal2 = resMap.get((int)resIR) + capMap.get((int)capIR) * 8 + gainMap.get(IRGain) * 256 + (IR2G?1:0) * 16384 + 32768;
    s.write(" ");
    s.write(hex(gainVal2));
    s.write("\n");
  } else {
    s.write(" ");
    s.write(hex(gainVal1));
    s.write("\n");
  }
  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> sent: " + hex(ctrlVal) + " " + hex(gainVal1) + "\n");
}

void updateValue() {
  int ctrlVal = 65536 + (int)(cur1/0.3) + (int)(cur2/0.3) * 256;
  int gainVal1 = resMap.get((int)resR) + capMap.get((int)capR) * 8 + gainMap.get(RGain) * 256 + (R2G?1:0) * 16384;
  int gainVal2 = resMap.get((int)resIR) + capMap.get((int)capIR) * 8 + gainMap.get(IRGain) * 256 + (IR2G?1:0) * 16384 + (eqGain?0:1) * 32768;
  text.setValue("Values:\nLEDCTRL: " + hex(ctrlVal) + "\nTIAAMBGAIN: " + hex(gainVal1) + "\nTIAGAIN: " + hex(gainVal2));
}

void controlEvent(ControlEvent theEvent) {
  /* events triggered by controllers are automatically forwarded to 
     the controlEvent method. by checking the name of a controller one can 
     distinguish which of the controllers has been changed.
  */
  
  
  // DropdownList is of type ControlGroup.
  // A controlEvent will be triggered from inside the ControlGroup class.
  // therefore you need to check the originator of the Event with
  // if (theEvent.isGroup())
  // to avoid an error message thrown by controlP5.
  if (theEvent.isGroup()) {
    // check if the Event was triggered from a ControlGroup
    println("event from group : "+theEvent.getGroup().getValue()+" from "+theEvent.getGroup());
    //check if there's a serial port open already, if so, close it
    if(s != null){
      s.stop();
      s = null;
    }
    //open the selected core
    String portName = serialPortsList.getItem((int)theEvent.getValue()).getName();
    try{
      s = new Serial(this,portName,BAUD_RATE);
    }catch(Exception e){
      System.err.println("Error opening serial port " + portName);
      e.printStackTrace();
    }
  } 
  else if (theEvent.isController()) {
    println("event from controller : "+theEvent.getController().getValue()+" from "+theEvent.getController());
  }
  
  
  if(theEvent.isController()) {
    
    print("control event from : "+theEvent.controller().getName());
    println(", value : "+theEvent.controller().getValue());
    
    if(theEvent.controller().getName()=="Single/Array") {
      if (SINGLE) {
        SINGLE = false;
        s.write("map");
        theEvent.controller().setCaptionLabel("Array");
        
      } else {
        SINGLE = true;
        s.write("map");
        theEvent.controller().setCaptionLabel("Single");
      }
    }
    
    if(theEvent.controller().getName()=="Enable Red Gain 2") {
      R2G = theEvent.controller().getValue() > 0;
      if (R2G) {
        g1.unlock();
        if (eqGain) {
          IR2G = true;
          t3.setValue(true);
        }
      }
      else {
        RGain = 0;
        g1.setValue(0);
        g1.lock();
        if (eqGain) {
          IRGain = 0;
          g2.setValue(0);
          IR2G = false;
          t3.setValue(false);
        }
      }
    }
    
    if(theEvent.controller().getName()=="Enable IRed Gain 2") {
      IR2G = theEvent.controller().getValue() > 0;
      if ((!eqGain) && IR2G) g2.unlock();
      else {
        IRGain = 0;
        g2.setValue(0);
        g2.lock();
      }      
    }
    
    if(theEvent.controller().getName()=="Same Gain 1") {
      eqGain = theEvent.controller().getValue() > 0;
      if (!eqGain) {
        r2.unlock(); c2.unlock(); t3.unlock();
      } else {
        resIR = resR; capIR = capR; IRGain = RGain; IR2G = R2G;
        r2.setValue(resIR); c2.setValue(capIR); g2.setValue(IRGain); t3.setValue(IR2G?1:0);
        r2.lock(); c2.lock(); g2.lock(); t3.lock();
      }
    }
    
    if(theEvent.controller().getName()=="Same Current") {
      eqCur = theEvent.controller().getValue() > 0;
      if (!eqCur) {
        i2.unlock();
      } else {
        cur2 = cur1;
        i2.setValue(cur2);
        i2.lock();
      }
    }    
      
    if(theEvent.controller().getName()=="Red Current" && !taskLock) {
      cur1 = getNearest(curList, theEvent.controller().getValue());
      taskLock = true;
      i1.setValue(cur1);
      taskLock = false;
      if (eqCur) {
        cur2 = cur1;
        i2.setValue(cur2);
      }
    }
    
    if(theEvent.controller().getName()=="IRed Current" && !taskLock) {
      cur2 = getNearest(curList, theEvent.controller().getValue());
      taskLock = true;
      i2.setValue(cur2);
      taskLock = false;
    }

    if(theEvent.controller().getName()=="Red Rf" && !taskLock) {
      resR = getNearest(resList, theEvent.controller().getValue());
      taskLock = true;
      r1.setValue(resR);
      taskLock = false;
      if (eqGain) {
        resIR = resR;
        r2.setValue(resIR);
      }
    }
    
    if(theEvent.controller().getName()=="IRed Rf" && !taskLock) {
      resIR = getNearest(resList, theEvent.controller().getValue());
      taskLock = true;
      r2.setValue(resIR);
      taskLock = false;
    }
 
    if(theEvent.controller().getName()=="Red Cf" && !taskLock) {
      capR = getNearest(capList, theEvent.controller().getValue());
      taskLock = true;
      c1.setValue(capR);
      taskLock = false;
      if (eqGain) {
        capIR = capR;
        c2.setValue(capIR);
      }
    }
    
    if(theEvent.controller().getName()=="IRed Cf" && !taskLock) {
      capIR = getNearest(capList, theEvent.controller().getValue());
      taskLock = true;
      c2.setValue(capIR);
      taskLock = false;
    }

    if(theEvent.controller().getName()=="Red Gain 2" && !taskLock) {
      RGain = getNearest(gainList, theEvent.controller().getValue());
      taskLock = true;
      g1.setValue(RGain);
      taskLock = false;
      if (eqGain) {
        IRGain = RGain;
        g2.setValue(RGain);
      }
    }
    
    if(theEvent.controller().getName()=="IRed Gain 2" && !taskLock) {
      IRGain = getNearest(gainList, theEvent.controller().getValue());
      taskLock = true;
      g2.setValue(IRGain);
      taskLock = false;
    }
    
    if(theEvent.controller().getName()=="send") {
      sendCommand();
    }
    
    if(theEvent.controller().getName()=="stop") {
      if (stopgraph) {
        stopgraph = false;
        theEvent.controller().setCaptionLabel("STOP");
      } else {
        stopgraph = true;
        theEvent.controller().setCaptionLabel("START");
      }
    }
    
    if(theEvent.controller().getName()=="save") {
      savedata = true;
      //plotSurfaceMap ();
    }
    
    if(theEvent.controller().getName()=="IR YMAX") {
      g.setYAxisMax(ir1.getValue());
    }
    
    if(theEvent.controller().getName()=="R YMAX") {
      h.setYAxisMax(ir2.getValue());
    }
    
    updateValue();
  }  
}

void serialEvent(Serial thisPort) {
  String nextParsed;
  if (thisPort == s) {
    nextParsed = thisPort.readStringUntil('\n');
    if (nextParsed != null) {
      //print(nextParsed);
      if (nextParsed.length() == 39) {
        timestamp = int(nextParsed.substring(0, 6));
        //print(timestamp);print(" ");
        pixelID = int(nextParsed.substring(7, 9));
        //print(pixelID);print(" ");
        Rdata = float(nextParsed.substring(10, 16));
        //print(Rdata);print(" ");
        Ramb = float(nextParsed.substring(17, 23));
        //print(Ramb);print(" ");
        IRdata = float(nextParsed.substring(24, 30));
        //print(IRdata);print(" ");
        IRamb = float(nextParsed.substring(31, 37));
        //print(IRamb);print("\n");
        text2.setValue("Raw Data:\nRdata: " + Rdata + "\nRamb: " + Ramb + "\nIRdata: " + IRdata+ "\nIRamb: " + IRamb);
      }
    }
  }
}

// mapping


