/*
  SerialBridge_lab08  --  ASEN 3503 Lab 8, Serial Port Communications

  ONE Arduino Due, loopback wiring (no second board needed):

      jumper wire:   Tx1 (pin 18)  --->  Rx2 (pin 17)      (both on the SAME Due)

      Computer (SerialTool, always 9600 8-N-1)  <--USB-->  Due
      Every character you type travels:
         USB Serial -> Serial1 TX (pin 18) -> jumper wire -> Serial2 RX (pin 17) -> USB Serial -> screen

  The USB link to your computer ALWAYS stays 9600 8-N-1. Only the Serial1 (transmit)
  and Serial2 (receive) settings change, so any framing mismatch happens on the real
  UART-to-UART wire between pin 18 and pin 17, which you can probe with the oscilloscope.
  (The same sketch also works between two Dues: Tx1 -> the other board's Rx2, and
   shared GND.)

  Commands -- type into SerialTool, then press Enter:
      ~TX <baud> <frame>   set how Serial1 TRANSMITS         e.g.  ~TX 2400 7E1
      ~RX <baud> <frame>   set how Serial2 RECEIVES          e.g.  ~RX 2400 8N1
      ~B <value>           send ONE raw byte (0-255, decimal or 0xHH) out Serial1,
                           e.g.  ~B 214     (a UTF-8 terminal cannot type a lone byte >= 128)
      ~H 1  /  ~H 0        byte report ON / OFF. ON prints each received byte as plain text,
                           e.g.   RX 0xE1 (225)      RX 0x61 (97) 'a'
                           OFF passes received bytes to the screen untouched (default).
      ~?                   print the current settings
  <frame> is data bits, parity, stop bits:  8N1  7N1  8E1  7E1  8O1  7O1

  A command runs only when you press Enter (CR or LF).

  Anything that does not start with '~' is sent out Serial1 as data. (A '~' itself
  therefore cannot be sent as data.) Power-up and reset defaults: TX and RX at
  9600 8N1, byte report OFF.
*/

// Frame names, in the same order as the switch in beginPort() below.
const char *FRAME_NAMES[] = {"8N1", "7N1", "8E1", "7E1", "8O1", "7O1"};
const int NUM_FRAMES = sizeof(FRAME_NAMES) / sizeof(FRAME_NAMES[0]);

const unsigned long USB_BAUD = 9600;   // fixed: computer <-> this Due
unsigned long txBaud = 9600, rxBaud = 9600;
int txFrame = 0, rxFrame = 0;          // index into FRAMES, 0 = 8N1
bool reportMode = false;

bool cmdMode = false;
char cmdBuf[40];
int cmdLen = 0;
char skipChar = 0;                     // swallows the 2nd half of a CR+LF after a command

int findFrame(const char *s) {
  for (int i = 0; i < NUM_FRAMES; i++) {
    if (strcasecmp(s, FRAME_NAMES[i]) == 0) return i;
  }
  return -1;
}

void printConfig() {
  Serial.print("TX (Serial1): ");
  Serial.print(txBaud);
  Serial.print(" ");
  Serial.println(FRAME_NAMES[txFrame]);
  Serial.print("RX (Serial2): ");
  Serial.print(rxBaud);
  Serial.print(" ");
  Serial.println(FRAME_NAMES[rxFrame]);
  Serial.print("Byte report: ");
  Serial.println(reportMode ? "ON" : "OFF");
}

// The Due core uses different enum types for the 8-bit and 7-bit frame constants,
// so each constant must be passed directly to begin() (not stored in a variable).
void beginPort(USARTClass &port, unsigned long baud, int frame) {
  switch (frame) {
    case 0: port.begin(baud, SERIAL_8N1); break;
    case 1: port.begin(baud, SERIAL_7N1); break;
    case 2: port.begin(baud, SERIAL_8E1); break;
    case 3: port.begin(baud, SERIAL_7E1); break;
    case 4: port.begin(baud, SERIAL_8O1); break;
    case 5: port.begin(baud, SERIAL_7O1); break;
  }
}

bool portsStarted = false;   // end() must not be called on a port that was never begun

void applyConfig() {
  if (portsStarted) {
    Serial1.end();
    Serial2.end();
  }
  portsStarted = true;
  beginPort(Serial1, txBaud, txFrame);
  beginPort(Serial2, rxBaud, rxFrame);
  delay(20);                           // let any start-up glitch on the wire pass...
  while (Serial2.available()) Serial2.read();   // ...and discard it
}

void reportByte(uint8_t b) {
  Serial.print("RX 0x");
  if (b < 16) Serial.print('0');
  Serial.print(b, HEX);
  Serial.print(" (");
  Serial.print(b);
  Serial.print(")");
  if (b >= 32 && b < 127) {
    Serial.print(" '");
    Serial.write(b);
    Serial.print("'");
  }
  Serial.println();
}

void printRawHex(const char *s, int maxBytes) {
  for (int i = 0; s[i] != '\0' && i < maxBytes; i++) {
    Serial.print(' ');
    if ((uint8_t)s[i] < 16) Serial.print('0');
    Serial.print((uint8_t)s[i], HEX);
  }
}

void handleCommand(char *line) {
  // line has the leading '~' removed, e.g. "TX 2400 7E1", "B 214", "H 1" or "?"
  char raw[40];
  strncpy(raw, line, sizeof(raw) - 1);
  raw[sizeof(raw) - 1] = '\0';
  // Treat tabs, stray control characters, and non-ASCII bytes as spaces,
  // and ignore leading spaces or extra '~' characters.
  for (char *p = line; *p; p++) {
    if ((uint8_t)*p < 32 || (uint8_t)*p > 126) *p = ' ';
  }
  while (*line == ' ' || *line == '~') line++;
  if (line[0] == '?') {
    printConfig();
    return;
  }
  char *cmd = strtok(line, " ");
  char *a1 = strtok(NULL, " ");
  char *a2 = strtok(NULL, " ");
  if (cmd == NULL) {
    Serial.println("Commands: ~TX <baud> <frame>  ~RX <baud> <frame>  ~B <byte>  ~H 1|0  ~?");
    return;
  }

  if (strcasecmp(cmd, "B") == 0) {
    if (a1 == NULL) {
      Serial.println("Usage: ~B <0-255 or 0xHH>");
      return;
    }
    char *end;
    long v = strtol(a1, &end, 0);
    if (end == a1 || *end != '\0' || v < 0 || v > 255) {
      Serial.println("Byte must be 0-255 (decimal) or 0x00-0xFF.");
      return;
    }
    Serial1.write((uint8_t)v);
    return;
  }

  if (strcasecmp(cmd, "H") == 0) {
    if (a1 == NULL || (a1[0] != '0' && a1[0] != '1')) {
      Serial.println("Usage: ~H 1  (report on)  or  ~H 0  (report off)");
      return;
    }
    reportMode = (a1[0] == '1');
    Serial.println(reportMode ? "Byte report ON" : "Byte report OFF");
    return;
  }

  if (strcasecmp(cmd, "TX") != 0 && strcasecmp(cmd, "RX") != 0) {
    Serial.print("Unknown command. Use ~TX, ~RX, ~B, ~H or ~?  Received bytes:");
    printRawHex(raw, 16);
    Serial.println();
    return;
  }
  if (a1 == NULL || a2 == NULL) {
    Serial.println("Usage: ~TX <baud> <frame>  or  ~RX <baud> <frame>");
    return;
  }
  unsigned long baud = strtoul(a1, NULL, 10);
  int fi = findFrame(a2);
  if (baud < 300 || baud > 115200 || fi < 0) {
    Serial.println("Bad baud (300-115200) or frame (8N1 7N1 8E1 7E1 8O1 7O1).");
    return;
  }
  if (strcasecmp(cmd, "TX") == 0) {
    txBaud = baud; txFrame = fi;
  } else {
    rxBaud = baud; rxFrame = fi;
  }
  applyConfig();
  printConfig();
}

// Run (or cancel, if empty) the command collected so far.
void finishCommand() {
  cmdBuf[cmdLen] = '\0';
  if (cmdLen > 0) handleCommand(cmdBuf);
  cmdMode = false;
  cmdLen = 0;
}

void setup() {
  Serial.begin(USB_BAUD);   // programming port -> computer, fixed 8N1
  Serial.println("SerialBridge_lab08 starting...");
  applyConfig();            // Serial1 / Serial2 start at 9600 8N1
  Serial.println("SerialBridge_lab08 ready. Type ~? for settings.");
}

void loop() {
  // Computer -> (command parser or) Serial1 TX
  while (Serial.available()) {
    char c = Serial.read();
    if (!cmdMode && skipChar) {
      char s = skipChar;
      skipChar = 0;
      if ((s == '\r' && c == '\n') || (s == '\n' && c == '\r')) continue;
    }
    if (cmdMode) {
      if (c == '\r' || c == '\n') {
        finishCommand();
        skipChar = c;
      } else if (cmdLen < (int)sizeof(cmdBuf) - 1) {
        cmdBuf[cmdLen++] = c;
      }
    } else if (c == '~') {
      cmdMode = true;
      cmdLen = 0;
    } else {
      Serial1.write(c);
    }
  }

  // Serial2 RX -> computer (raw byte, or a plain-text report of its value)
  while (Serial2.available()) {
    uint8_t b = Serial2.read();
    if (reportMode) reportByte(b);
    else Serial.write(b);
  }
}
