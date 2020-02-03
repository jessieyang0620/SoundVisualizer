import processing.sound.*;
/*
CC Drawing Machine V3
By Jessie Yang
Date 8 July 2019

Purpose: ball that visually reflects audio input (amplitude and frequency)

Requirements:
1. Must include one of each of the following:
      - circle (dots)
      - rectangle (rewind screen)        *
      - line (rewind screen)             *
      - custom shape (arc of dots, rewind triangle) *
     * = new since crit
     
2. Must include at least 2 inputs
      - mic (audio)
      - keyboard (key presses)
      
      
Updates since Saturday crit/what's new:

New key commands --
* c to clear        
* r to rewind       
* p to pause        
* s to screenshot   
* esc to close program

New audio input --
* Frequency representation - ball gets lighter the higher the frequency, darker the lower


Note: amplitude still controls ball radius
*/

/*---------------------------------------------------------------------------------------------*/


// audio input, amplitude, frequency
AudioIn in;
final static int multiplier = 1000; // scales amplitude and freq up for convenience

int a;   //amplitude
Amplitude amp;

int f;  // frequency
FFT fft;
int bands = 512; //# frequency channels
float spectrum[] = new float[bands];

boolean play;    // or pause
boolean forward; //or rewind

//general things
final static int fps = 70;
final static int swidth = 800;
final static int sheight = 800;

int bgColor = 127; //mid grey
int ballColor;

//path of dots, with help from tutorial
float beginX = 0;  // Initial x-coordinate
float beginY = 0;  // Initial y-coordinate
float endX = 570.0;   // Final x-coordinate
float endY = 320.0;   // Final y-coordinate
float distX;          // X-axis distance to move
float distY;          // Y-axis distance to move
float Yexponent = 5;   // Determines the curve
float Xexponent = 2;
float x = 0.0;        // Current x-coordinate
float y = 0.0;        // Current y-coordinate
float step = 0.01;    // Size of each step along the path
float pct = 0.0;      // Percentage traveled (0.0 to 1.0)

ArrayList<Point> points = new ArrayList<Point>(); // list to save all points to for rewind

// initializes screen
void setup() {
  //general
  frameRate(fps);
  size(800, 800);
  background(bgColor);
  noStroke();
  
  //audio-specific things
  in = new AudioIn(this, 0);
  amp = new Amplitude(this);
  fft = new FFT(this, bands);
  
  //starts reading mic data
  in.start();
  amp.input(in);
  fft.input(in);
  
  //starts play and forward as true
  play = true;
  forward = true;
  
  //begins arc
  distX = endX - beginX;
  distY = endY - beginY;
}

//draws each frame
void draw() {
  f = normalizeFreq();
  a = normalizeAmp();
  
  if(forward){
    pct += step;
    if (pct < 1.0) {
       decideFill();
       moveCircle();
       drawCircle();
    }
    else {
      newTarget();
    }
  }
  else{ // reverse
    int i = points.size()-1;
    if(!(i < 0)){
    fill(bgColor);
    circle(points.get(i).getX(), points.get(i).getY(), points.get(i).getRad() + 2); // note: +2 is because
                                                                                    // there is a slight outline 
                                                                                    // if the radii are the same
    points.remove(i);
    }
    else
      blink();
    }
   // screenshot();
  }
  
//decides color of circle based on frequency (higher freq = white, 
// lower freq = black)
void decideFill(){
  if (f < 256 && f > 0) 
    ballColor = f;
  else if (f >=256) 
    ballColor = 255;
  else
    ballColor = 0;
    
  fill(ballColor);
}

//scales amplitude reading
int normalizeAmp(){
  return (int) (amp.analyze() * multiplier);
}

//sums frequencies into one
int normalizeFreq(){
  fft.analyze(spectrum);
  int sumFreq = 0;
  for(int i = 0; i < bands; i++){
    sumFreq += spectrum[i] * multiplier;
  }
  return sumFreq;
}

// moves to next dot in path
void moveCircle(){
    x = beginX + (pow(pct, Xexponent) * distX);
    y = beginY + (pow(pct, Yexponent) * distY);
}

//picks new goal/end of path
void newTarget(){
  pct = 0;
  beginX = x;
  beginY = y;
  endX = random(swidth);
  endY = random(sheight);
  distX = endX - beginX;
  distY = endY - beginY;
}

//draws each point in path, adds to list of points
void drawCircle(){
  circle(x, y, a);
  points.add(new Point(x, y, a));
}

//blinks the screen black, exits after 2 seconds
void blink(){
  background(0);
  delay(2000);
  exit();
}

//handles key presses
void keyPressed(){
  if(key == 'c' || key == 'C')
      clear();
  if(key == 'r' || key == 'R')
      rewind();
  if(key == 'p' || key == 'P')
      pause();
  if(key == 's' || key == 'S')
      screenshot();
  if(keyCode == ESC)
      exit();
}

//clears screen (c)
void clear(){
  background(bgColor);
}

//pauses program (p)
void pause(){
  play = !play; //toggles play
  
  if(!play){ //paused
    noLoop();
  }
  else{ //play
    loop();
  }
}

//rewinds visuals
void rewind(){
  forward = false;
  drawRewind();
}

// draws a rewind button
void drawRewind(){
  int size = 50;
  fill(90, 50);
  rect(0,0,size,size);
  
  stroke(70);
  strokeWeight(7);
  line(size/4, size/2, size*3/4, size/4);
  line(size*3/4, size/4, size*3/4, size*3/4);
  line(size/4, size/2, size*3/4, size*3/4);
  
  noStroke();
}

//takes screenshot (s)
void screenshot(){
  saveFrame("gif-####.jpg");
}
