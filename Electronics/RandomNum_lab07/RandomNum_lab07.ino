long randNumber;

void setup(){
  // if analog input pin 0 is unconnected, random analog
  // noise will cause the call to randomSeed() to generate
  // different seed numbers each time the sketch runs.
  // randomSeed() will then shuffle the random function.
  randomSeed(analogRead(0));
  pinMode(13, OUTPUT);
}

void loop() {
  // blink LED to signal "Get ready"
  for(int j=1; j<25;j++){
    digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(100);               // wait
    digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
    delay(100);               // wait
  }
  
  delay(2000);               // wait 2 sec to start
  digitalWrite(13, HIGH);   // turn the LED on while computing random number/summing

  // generate and sum 5e6 random numbers
  randNumber = random(1,300);
  for(int i = 1; i<5e6; i++){
    randNumber = randNumber + random(1,300);
  }

  digitalWrite(13, LOW);   // turn the LED on while computing random number/summing
  delay(2000);               // wait 2 sec to start
   
  // blink LED to signal the end
  for(int j=1; j<25;j++){
    digitalWrite(13, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(100);               // wait
    digitalWrite(13, LOW);    // turn the LED off by making the voltage LOW
    delay(100);               // wait
  }
  delay(1000000);  //wait a looong time (1000s) before looping again 
   
}

