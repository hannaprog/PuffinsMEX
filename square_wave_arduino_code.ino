// Test run for CoolTerm CSV output - Marko 04-03-2026

#include <Servo.h>          // ADDED
Servo esc;                  // ADDED
int escPin = 9;             // ADDED
int currentPin = A0;        // ADDED for ACS712 current sensor

unsigned long startTime;

// PWM steps (PPM microseconds) forward and backward
const int forward_steps[]  = {1600, 1700, 1800, 1900};
const int backward_steps[] = {1400, 1300, 1200, 1100}; // mirror below 1500

const int number_forward_steps  = sizeof(forward_steps) / sizeof(forward_steps[0]);
const int number_backward_steps = sizeof(backward_steps) / sizeof(backward_steps[0]);

// Step durations in milliseconds (long -> short)
const unsigned long time_durations[] = {2000, 1000, 500, 250, 125};
const int number_time_durations = sizeof(time_durations) / sizeof(time_durations[0]);

// Sampling period: 80 Hz = 12.5 ms = 12500 µs
const unsigned long sample_period = 12500;
unsigned long last_sample_time = 0;

void setup() {
  Serial.begin(115200);   // initialize serial for CSV

  esc.attach(escPin);     // ADDED
  esc.writeMicroseconds(1500); // ADDED (neutral / arm)
  delay(5000);            // ADDED (ESC arm time)

  Serial.println(1500); // neutral
  delay(1000);          // small delay before start

  startTime = micros();
  last_sample_time = startTime;
}

void loop() {

  // ----------- FORWARD STEPS (PWM > 1500) -----------
  for (int s = 0; s < number_forward_steps; s++) {
    int pwmValue = forward_steps[s];

    for (int u = 0; u < number_time_durations; u++) {

      unsigned long up_duration_us   = time_durations[u] * 1000UL;
      unsigned long down_duration_us = 1000000;

      // UP PHASE
      unsigned long up_start_time = micros();
      while (micros() - up_start_time < up_duration_us) {
        unsigned long now = micros();
        if (now - last_sample_time >= sample_period) {
          last_sample_time += sample_period;

          esc.writeMicroseconds(pwmValue); // ADDED

          Serial.print( ((double)(now - startTime)) / 1000000.0, 6 );
          Serial.print(",");
          Serial.print(pwmValue);
          Serial.print(",");
          int currentRaw = analogRead(currentPin); // ADDED
          Serial.println(currentRaw);               // ADDED
        }
      }

      // DOWN PHASE (NEUTRAL)
      unsigned long down_start_time = micros();
      while (micros() - down_start_time < down_duration_us) {
        unsigned long now = micros();
        if (now - last_sample_time >= sample_period) {
          last_sample_time += sample_period;

          esc.writeMicroseconds(1500); // ADDED

          Serial.print( ((double)(now - startTime)) / 1000000.0, 6 );
          Serial.print(",");
          Serial.print(1500); // neutral
          Serial.print(",");
          int currentRaw = analogRead(currentPin); // ADDED
          Serial.println(currentRaw);               // ADDED
        }
      }
    }
  }

  // ----------- LONGER BREAK AFTER LAST FORWARD STEP -----------
  unsigned long break_start = micros();
  while (micros() - break_start < 2000000UL) { // 2 s pause
    unsigned long now = micros();
    if (now - last_sample_time >= sample_period) {
      last_sample_time += sample_period;

      esc.writeMicroseconds(1500); // ADDED

      Serial.print( ((double)(now - startTime)) / 1000000.0, 6 );
      Serial.print(",");
      Serial.print(1500); // neutral
      Serial.print(",");
      int currentRaw = analogRead(currentPin); // ADDED
      Serial.println(currentRaw);               // ADDED
    }
  }

  // ----------- BACKWARD STEPS (PWM < 1500) -----------
  for (int s = 0; s < number_backward_steps; s++) {
    int pwmValue = backward_steps[s];

    for (int u = 0; u < number_time_durations; u++) {

      unsigned long up_duration_us   = time_durations[u] * 1000UL;
      unsigned long down_duration_us = 1000000;

      // UP PHASE (backward)
      unsigned long up_start_time = micros();
      while (micros() - up_start_time < up_duration_us) {
        unsigned long now = micros();
        if (now - last_sample_time >= sample_period) {
          last_sample_time += sample_period;

          esc.writeMicroseconds(pwmValue); // ADDED

          Serial.print( ((double)(now - startTime)) / 1000000.0, 6 );
          Serial.print(",");
          Serial.print(pwmValue);
          Serial.print(",");
          int currentRaw = analogRead(currentPin); // ADDED
          Serial.println(currentRaw);               // ADDED
        }
      }

      // DOWN PHASE (NEUTRAL)
      unsigned long down_start_time = micros();
      while (micros() - down_start_time < down_duration_us) {
        unsigned long now = micros();
        if (now - last_sample_time >= sample_period) {
          last_sample_time += sample_period;

          esc.writeMicroseconds(1500); // ADDED

          Serial.print( ((double)(now - startTime)) / 1000000.0, 6 );
          Serial.print(",");
          Serial.print(1500); // neutral
          Serial.print(",");
          int currentRaw = analogRead(currentPin); // ADDED
          Serial.println(currentRaw);               // ADDED
        }
      }
    }
  }

  while(true); // stop after full test run
}
