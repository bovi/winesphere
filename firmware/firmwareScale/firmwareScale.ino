/*
 *  Winesphere Scale Firmware 
 *  
 *  This firmware was implemented to collect weight
 *  values of the Wine with a scale.
 *  
 *  Version: 1 [2019-11-26]
 */

#include "EEPROM.h"
#include "esp_system.h"
#include <M5StickC.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <HX711_ADC.h>
HX711_ADC LoadCell(33, 32);

int addr = 0;
#define EEPROM_SIZE 64

const int wdtTimeout = 25000;  //time in ms to trigger the watchdog
hw_timer_t *timer = NULL;

const char* ssid     = "MINDDOT";
const char* password = "88minddot88";
const char* url      = "http://47.75.204.82/new_weight";
//const char* url      = "http://192.168.111.56:3000/new_weight";

char* deviceName = "winesphereScale01";

void IRAM_ATTR resetModule() {
  ets_printf("reboot\n");
  esp_restart();
}

void setTxt(uint x, uint y, char* txt) {
  M5.Lcd.setCursor(x, y);
  M5.Lcd.fillRect(x, y, 110, 8, BLACK);
  M5.Lcd.printf(txt);
}

uint32_t setUptime() {
  char uptime[20];
  uint32_t uptime_millis = millis();
  sprintf(uptime, "%dmin, %dsec", (uptime_millis / 1000) / 60, (uptime_millis / 1000)%60);
  setTxt(55, 50, uptime);
  return uptime_millis;
}

float setWeight() {
  char weight[20];
  long count = 10;
  float sum = 0;
  float result = 0;
  float tmp = 0;

  if (!EEPROM.begin(EEPROM_SIZE)) {
    /* reboot if EEPROM can't be initialized */
    Serial.println("failed to initialise EEPROM");
    ESP.restart();
  } else {
    /* do we want to reset the offset? */
    if (M5.BtnA.isPressed()) {
      /* user visualization that we start writing the offset */
      pinMode(10, OUTPUT);
      digitalWrite(10, LOW);
      
      /* write current offset to EEPROM */
      long _offset = LoadCell.getTareOffset();
      EEPROM.writeLong(addr, _offset);
      EEPROM.commit();

      /* user visualization that we have saved the offset */
      delay(5000);
      digitalWrite(10, HIGH);

      /* restart ESP after saving offset */
      ESP.restart();
    } else {
      /* load current offset */
      long _offset = EEPROM.readLong(addr);
      LoadCell.setTareOffset(_offset);
    }
  }
  
  /* wait until load cell is ready. then get data */
  while (!LoadCell.update());
  result = LoadCell.getData();
  
  sprintf(weight, "%.2f", result);
  setTxt(55, 30, weight);

  return result;
}

float setBattery() {
  char battery[20];
  float voltage = M5.Axp.GetBatVoltage();
  sprintf(battery, "%.3fV", M5.Axp.GetBatVoltage());
  setTxt(55, 60, battery);
  return voltage;
}

uint32_t ok = 0;
uint32_t ko = 0;
void setOK() {
  ok += 1;
  setOKKO();
}
void setKO() {
  ko += 1;
  setOKKO();
}
void setOKKO() {
  char okko[20];
  sprintf(okko, "%d / %d", ok, ko);
  setTxt(55, 40, okko);
}

void setState() {
  char state[20];
  IPAddress ip = WiFi.localIP();
  
  if (WiFi.status() == WL_CONNECTED)
    sprintf(state, "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
  else
    sprintf(state, "not connected");

  setTxt(55, 20, state);
}

void setup() {
  Serial.begin(115200);

  /* initialize load cells */
  LoadCell.begin();
  long stabilisingtime = 2000;
  LoadCell.start(stabilisingtime);
  if (LoadCell.getTareTimeoutFlag()) {
    Serial.println("Tare timeout, check MCU>HX711 wiring and pin designations");
    ESP.restart();
  }
  else {
    LoadCell.setCalFactor(696.0); // set calibration factor (float)
    Serial.println("Startup + tare is complete");
  }
  if (LoadCell.getSPS() < 7) {
    Serial.println("!!Sampling rate is lower than specification, check MCU>HX711 wiring and pin designations");
    ESP.restart();
  }
  else if (LoadCell.getSPS() > 100) {
    Serial.println("!!Sampling rate is higher than specification, check MCU>HX711 wiring and pin designations");
    ESP.restart();
  }

  /* initialize watchdog timer */
  timer = timerBegin(0, 80, true);                  //timer 0, div 80
  timerAttachInterrupt(timer, &resetModule, true);  //attach callback
  timerAlarmWrite(timer, wdtTimeout * 1000, false); //set time in us
  timerAlarmEnable(timer);

  /* initialize display */
  M5.begin();
  M5.Lcd.setRotation(1);
  M5.Lcd.fillScreen(BLACK);
  M5.Lcd.setTextColor(WHITE);
  M5.Lcd.setTextSize(1);

  setTxt(0, 10, "     ID: ");
  setTxt(0, 20, "  State: ");
  setTxt(0, 30, " Weight: ");
  setTxt(0, 40, "  OK/KO: ");
  setTxt(0, 50, " Uptime: ");
  setTxt(0, 60, "Battery: ");
  
  setTxt(55, 10, deviceName);
  setUptime();
  setBattery();

  float weight = setWeight();

  Serial.println("Try to connect to Wifi");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    setUptime();
    setBattery();

    /* restart ESP if it can't connect to wifi */
    if (millis() > (1000 * 15))
      ESP.restart();
  }
  Serial.println("Connected");

  /* update state and send data to cloud */
  setState();
  sendData(weight);

  ESP.restart();
}

bool sendData(float weight) {
  char json[255];
  HTTPClient http;

  for (int i=0; i<5; i++) {
    sprintf(json, "data={\"scale\": \"%s\", \"weight\": %.3f, \"battery\": %.3f, \"uptime\": %lu}",
                                      deviceName,       weight,       setBattery(),     setUptime());
    http.begin(url);
    Serial.println(json);
    int httpResponseCode = http.POST(json);
    Serial.print("HTTP Code: ");
    Serial.println(httpResponseCode);
    if (httpResponseCode == 200) {
      setOK();
      break;
    } else {
      setKO();
    }
    http.end();
    delay(1000);
  }
}

void loop() {}
