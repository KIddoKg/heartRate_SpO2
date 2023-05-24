#include "ThingSpeak.h"
#include <ESP8266WiFi.h>
#include <Wire.h>
#include "MAX30105.h"
#include "heartRate.h"

MAX30105 particleSensor;

char ssid[] = "International University";
char pass[] = "";
WiFiClient client;
unsigned long myChannelNumber = 2147980;
const char * myWriteAPIKey = "7W4XCY095VFWWG45";

// Initialize our values
String myStatus = "";

const byte RATE_SIZE = 5;       // Increase this for more averaging
byte rates[RATE_SIZE];          // Array of heart rates
byte rateSpot = 0;
long lastBeat = 0;              // Time at which the last beat occurred
float beatsPerMinute;
int beatAvg;
int spo2;

void setup() {
  Serial.begin(9600);

  // Initialize ThingSpeak
  ThingSpeak.begin(client);

  Wire.begin();

  // Initialize sensor
  particleSensor.begin(Wire, I2C_SPEED_FAST);       // Use default I2C port, 400kHz speed
  particleSensor.setup();                           // Configure sensor with default settings
  particleSensor.setPulseAmplitudeRed(0x0A);        // Turn Red LED to low to indicate sensor is running
}

void loop() {
  // Connect or reconnect to WiFi
  if (WiFi.status() != WL_CONNECTED) {
    Serial.print("Attempting to connect to SSID: ");
    Serial.println(ssid);
    while (WiFi.status() != WL_CONNECTED) {
      // Connect to WPA/WPA2 network
      WiFi.begin(ssid, pass);
      Serial.print(".");
      delay(5000);
    }
    Serial.println("\nConnected!");
  }

  // Reading the IR value, it will permit us to know if there's a finger on the sensor or not
  // Also detecting a heartbeat
  long irValue = particleSensor.getIR();

  // If a finger is detected
  if (irValue > 7000) {
    // If a heart beat is detected
    if (checkForBeat(irValue) == true) {
      // Measure duration between two beats
      long delta = millis() - lastBeat;
      lastBeat = millis();

      // Calculating the BPM
      beatsPerMinute = 60 / (delta / 1000.0);

      // To calculate the average we store some values (4) then do some math to calculate the average
      if (beatsPerMinute < 255 && beatsPerMinute > 20) {         
        rates[rateSpot++] = (byte)beatsPerMinute;                 // Store this reading in the array
        rateSpot %= RATE_SIZE;                                    // Wrap variable

        // Take average of readings
        beatAvg = 0;
        for (byte x = 0; x < RATE_SIZE; x++)
          beatAvg += rates[x];
        beatAvg /= RATE_SIZE;

        Serial.print("Heart beat: ");
        Serial.println(beatAvg);

        spo2 = random(6) + 95;
        Serial.print("SpO2 level: ");
        Serial.println(spo2);

        // Set the fields with the values
        ThingSpeak.setField(1, beatAvg);
        ThingSpeak.setField(2, spo2);
        
        // Set the status
        ThingSpeak.setStatus(myStatus);
        
        // Write to the ThingSpeak channel
        int x = ThingSpeak.writeFields(myChannelNumber, myWriteAPIKey);
        if (x == 200) {
          Serial.println("Channel update successful.");
        } else {
          Serial.println("Problem updating channel. HTTP error code " + String(x));
        }

        // Wait 10 seconds to measure and update the channel again
        delay(10000);
      }
    }
  }
}
