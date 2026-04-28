// ======================================================
// PINS
// ======================================================

const int dirPin = 2;
const int stepPin = 3;
const int currentSensorPin = A0;

// ======================================================
// CURRENT SENSOR: ACS712-20A
// ======================================================

const float VREF = 5.0;
const int ADC_MAX = 1023;

// ACS712-20A sensitivity = 100 mV/A
const float sensitivity = 0.100;

// Fixed zero point. Ideally 512 for 5V ADC and 2.5 V zero current.
float calibratedZeroADC = 512.0;

float current_A = 0.0;

// ======================================================
// STEPPER SETTINGS
// ======================================================

const int motorFullStepsPerRevolution = 200;

// DRV8825 default is full step if MODE pins are not connected
const int microstepping = 1;

const int stepsPerRevolution = motorFullStepsPerRevolution * microstepping;

// Start low first. Increase later if everything works.
const float maxRPM = 100.0;
const float minRPM = 20.0;
const float controlDeadband = 0.05;

// ======================================================
// TEST CONTROL SIGNAL
// ======================================================

float controlSignal = 0.0;
float rpmCommand = 0.0;

// One full sine wave: 0 -> 1 -> 0 -> -1 -> 0
const float testPeriod_s = 30.0;

// ======================================================
// LINEAR MOTION SETTINGS
// ======================================================

// Lead screw pitch: 2 mm per revolution
const float leadScrewPitch_m = 0.002;

const float distancePerStep_m = leadScrewPitch_m / stepsPerRevolution;

// Piston starts at minimum position
float pistonPosition_m = 0.0;

const float pistonMin_m = 0.0;

// Mechanical max is 20 cm, but use 19.5 cm as safety limit
const float pistonMax_m = 0.195;

int direction = 1;

// ======================================================
// STEP CONTROL
// ======================================================

unsigned long lastStepTime_us = 0;
bool stepState = false;

// ======================================================
// TIMING
// ======================================================

const unsigned long currentInterval_ms = 10; // 100 Hz
const unsigned long printInterval_ms = 100;  // 10 Hz

unsigned long lastCurrentTime_ms = 0;
unsigned long lastPrintTime_ms = 0;
unsigned long startTime_ms = 0;

// ======================================================
// CURRENT SENSOR FUNCTIONS
// ======================================================

float readCurrentRaw() {
  int rawADC = analogRead(currentSensorPin);

  float voltage = (rawADC / (float)ADC_MAX) * VREF;
  float zeroVoltage = (calibratedZeroADC / (float)ADC_MAX) * VREF;

  float current = (voltage - zeroVoltage) / sensitivity;

  return current;
}

void updateCurrentSensor() {
  current_A = readCurrentRaw();
}

// ======================================================
// CONTROL SIGNAL FUNCTIONS
// ======================================================

float generateTestControlSignal() {
  const unsigned long onTime_ms = 3000;
  const unsigned long offTime_ms = 3000;
  const unsigned long period_ms = onTime_ms + offTime_ms;

  unsigned long time_ms = millis() - startTime_ms;
  unsigned long phaseTime_ms = time_ms % period_ms;

  if (phaseTime_ms < onTime_ms) {
    return 1.0;   // motor on
  } else {
    return 0.0;   // motor off
  }
}

float controlSignalToRPM(float u) {
  float absU = abs(u);

  if (absU < controlDeadband) {
    return 0.0;
  }

  return minRPM + absU * (maxRPM - minRPM);
}

void updateDirectionFromControlSignal(float u) {
  if (u >= 0) {
    direction = 1;
    digitalWrite(dirPin, HIGH);
  } else {
    direction = -1;
    digitalWrite(dirPin, LOW);
  }
}

// ======================================================
// STEPPER FUNCTION
// ======================================================

void updateStepper(float rpm, bool enable) {
  if (!enable || rpm <= 0) {
    digitalWrite(stepPin, LOW);
    stepState = false;
    return;
  }

  // Safety limits
  if (direction == 1 && pistonPosition_m >= pistonMax_m) {
    digitalWrite(stepPin, LOW);
    stepState = false;
    return;
  }

  if (direction == -1 && pistonPosition_m <= pistonMin_m) {
    digitalWrite(stepPin, LOW);
    stepState = false;
    return;
  }

  float stepFreq = (rpm / 60.0) * stepsPerRevolution;

  unsigned long halfPeriod_us =
    (unsigned long)((1000000.0 / stepFreq) / 2.0);

  unsigned long now_us = micros();

  if (now_us - lastStepTime_us >= halfPeriod_us) {
    lastStepTime_us = now_us;

    stepState = !stepState;
    digitalWrite(stepPin, stepState);

    // Count position only on rising edge
    if (stepState == HIGH) {
      pistonPosition_m += direction * distancePerStep_m;

      if (pistonPosition_m > pistonMax_m) {
        pistonPosition_m = pistonMax_m;
      }

      if (pistonPosition_m < pistonMin_m) {
        pistonPosition_m = pistonMin_m;
      }
    }
  }
}

// ======================================================
// PRINT FUNCTION
// ======================================================

void printData() {
  float time_s = (millis() - startTime_ms) / 1000.0;

  Serial.print(time_s, 3);
  Serial.print(",");

  Serial.print(controlSignal, 3);
  Serial.print(",");

  Serial.print(rpmCommand, 1);
  Serial.print(",");

  Serial.print(current_A, 4);
  Serial.print(",");

  Serial.println(pistonPosition_m, 5);
}

// ======================================================
// SETUP
// ======================================================

void setup() {
  Serial.begin(115200);

  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(currentSensorPin, INPUT);

  digitalWrite(stepPin, LOW);
  digitalWrite(dirPin, HIGH);

  pistonPosition_m = pistonMin_m;

  startTime_ms = millis();
  lastCurrentTime_ms = millis();
  lastPrintTime_ms = millis();

  Serial.println("time_s,controlSignal,rpmCommand,current_A,piston_m");
}

// ======================================================
// LOOP
// ======================================================

void loop() {
  unsigned long now_ms = millis();

  // Generate signal as often as possible
  controlSignal = generateTestControlSignal();

  // Convert control signal to direction and rpm
  updateDirectionFromControlSignal(controlSignal);
  rpmCommand = controlSignalToRPM(controlSignal);

  // Read current sensor at 100 Hz
  if (now_ms - lastCurrentTime_ms >= currentInterval_ms) {
    lastCurrentTime_ms += currentInterval_ms;
    updateCurrentSensor();
  }

  // Run stepper as often as possible
  updateStepper(rpmCommand, true);

  // Print CSV at 10 Hz
  if (now_ms - lastPrintTime_ms >= printInterval_ms) {
    lastPrintTime_ms += printInterval_ms;
    printData();
  }
}
}