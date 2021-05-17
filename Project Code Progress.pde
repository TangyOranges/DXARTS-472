/* 
 Actuate a servo motor in Arduino in Firmata 
 by using face detection in OpenCV
 
 by Afroditi Psarra
 February 2018
 */

import gab.opencv.*; // import openCV library
import processing.video.*; // import video library
import java.awt.*; 


import processing.serial.*; // import the serial library
import cc.arduino.*; // import the arduino (firmata) library

Arduino arduino; // create an arduino object

Capture video; 
OpenCV opencv;

int led = 6; // led connected to digital pin 6
int brightness; // variable to store the led's pwm value

int servo = 3; // servo connected to digital pin 3
int servo2 = 9;
int servoAngle; // variable to store the servo's angle
int servoAngle2;

void setup() {
  size(1280, 720);
  video = new Capture(this, 1280/2, 720/2);
  opencv = new OpenCV(this, 1280/2, 720/2);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);  

  video.start();

  // Prints out the available serial ports.
  println(Arduino.list());
  // Modify this line, by changing the "0" to the index of the serial
  // port corresponding to your Arduino board (as it appears in the list
  // printed by the line above).
  arduino = new Arduino(this, Arduino.list()[0], 57600);
  arduino.pinMode(led, Arduino.OUTPUT); // declare led connected to digital pin 6 as an output
  arduino.pinMode(servo, Arduino.SERVO); // declare servo connected to digital pin 4 as a servo object
  arduino.pinMode(servo2, Arduino.SERVO);
} 

void draw() {
  scale(2);
  opencv.loadImage(video);
  image(video, 0, 0 );
  filter(GRAY);
  fill(random(0, 255), random(0, 255), random(0, 255)); // fill the circle with an RGB color, controlling the red value with brightness
  noStroke();
  //strokeWeight(3);
  Rectangle[] faces = opencv.detect();
  println(faces.length); // print how many faces are detected

  for (int i = 0; i < faces.length; i++) {
    println(faces[i].x + "," + faces[i].y); // print the x,y coordinates of the faces
    ellipseMode(CORNER); // draw a circle from the corner
    ellipse(faces[i].x, faces[i].y, faces[i].width, faces[i].height); // draw a circle over the face's coordinates
    servoAngle = constrain(faces[i].x, 0, 640); // use the x coordinate of the detected face to control the angle of the servo
    arduino.servoWrite(servo, servoAngle / 4); // move the servo
      //servoAngle2 = constrain(faces[i].y, 0, 180);
      //arduino.servoWrite(servo2, servoAngle2);
    brightness = constrain(faces[i].y, 0, 255); // use the y coordinate of the detected face to control the led's brightness
    arduino.analogWrite(led, brightness); // fade the led      
    }
  
}

void captureEvent(Capture c) {
  c.read();
}
