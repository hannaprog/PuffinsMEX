#include <Servo.h>      // ADDED
Servo esc;              // ADDED
int escPin = 9;         // ADDED

// Neutral and amplitude
const int neutral = 1500;    // neutral PWM
const int amplitude = 400;   // swing ±400 µs → 1100–1900

// Frequencies for variation (Hz)
const float frequencies[] = {0.1, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0};
const int numFreq = sizeof(frequencies)/sizeof(frequencies[0]);

// Sampling period 80Hz → 12.5ms
const unsigned long samplePeriod = 12500; // microseconds
unsigned long lastSampleTime = 0;

unsigned long startTime;

void setup() {
  Serial.begin(115200);           // Initialize serial for CoolTerm

  esc.attach(escPin);             // ADDED
  esc.writeMicroseconds(neutral); // ADDED
  delay(5000);                    // ADDED (ESC arming)

  delay(1000);                  // small delay before start
  startTime = micros();
  lastSampleTime = startTime;
  
  Serial.println("time_s,pwm_us"); // CSV header (seconds for x-axis)
}

void loop() {
  // Loop through all frequencies
  for (int f = 0; f < numFreq; f++) {
    float freq = frequencies[f];
    float period = 1.0 / freq;                 // seconds
    unsigned long duration = period * 2 * 1000000UL; // 2 full cycles

    unsigned long loopStart = micros();
    while (micros() - loopStart < duration) {
      unsigned long now = micros();
      if (now - lastSampleTime >= samplePeriod) {
        lastSampleTime += samplePeriod;  // keep exact 80Hz spacing

        float t = (now - loopStart) / 1000000.0;       // seconds relative to this frequency
        int pwmValue = neutral + (int)(amplitude * sin(2 * 3.14159 * freq * t));

        esc.writeMicroseconds(pwmValue); // ADDED

        // CSV output: time in seconds vs PWM
        Serial.print((now - startTime) / 1000000.0, 5); // 5 decimals for smooth plotting
        Serial.print(",");
        Serial.println(pwmValue);
      }
    }
    // Pause between frequencies (neutral for 1 second)
    unsigned long pauseStart = micros();
    while (micros() - pauseStart < 1000000UL) {
      // Keep neutral during pause
      unsigned long now = micros();
      if (now - lastSampleTime >= samplePeriod) {
        lastSampleTime += samplePeriod;

        esc.writeMicroseconds(neutral); // ADDED

        Serial.print((now - startTime) / 1000000.0, 5);
        Serial.print(",");
        Serial.println(neutral);
      }
    }
  }

  while(true); // stop after all frequencies
}
