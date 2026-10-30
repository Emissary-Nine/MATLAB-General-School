int analogpin = 0;
int bin_val = 0;
void setup() {
  // put your setup code here, to run once:
  analogReadResolution(12);
  Serial.begin(57600);
  Serial.flush();
}

void loop() {
  // put your main code here, to run repeatedly:
  bin_val = analogRead(analogpin);
  Serial.println(bin_val,DEC);
  delayMicroseconds(1000);
}
