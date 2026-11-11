/*

  ASEN 3503 Lab 8 Serial Communication - Arduino ADC
  VoltageToADC.ino
  Created: February 6, 2013
  Author: Samantha Archambault
  
  Description:
  Attach the positive voltage wire to pin A5, and the negative
  voltage wire to ground (GND). Reads the 12-bit ADC value (0-4095)
  from pin A5, maps it to an 8-bit value (0-255), and prints that
  value in hex to the serial monitor (9600 baud) once per second.
  
  Compile:
  Simply select the correct serial port in Tools -> Serial Port
  and push the Upload button in the user interface.
 
 */

// define analog pin 5 as the input sensor value
int analogPin = A5;

// the setup routine runs once when you press reset:
void setup() {
  
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  
}

// the loop routine runs over and over again forever:
void loop() {
  
  // Set the Due's ADC to 12-bit resolution
analogReadResolution(12);

  // read the input on analog pin A5:
  int analogValue = analogRead(analogPin);

  // map 12 bit to 8 bit:
  int decVal = map(analogValue, 0, 4095, 0, 255);
  
  // print the 8-bit value as a hex value:
  Serial.println(decVal, HEX);
 
  // delay for one second
  delay(1000);
  
}
