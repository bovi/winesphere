/*
 *  Winesphere Thermocoupler Firmware 
 *  
 *  This firmware was implemented to collect temperature
 *  values of the Wine with a thermocoupler.
 *  
 *  Test on 2019-11-18[v1]: 49minutes on Battery shut-off at around 3V
 *  
 *  Version: 3 [2019-11-25]
 */

#include "esp_system.h"
#include <M5StickC.h>
#include <WiFi.h>
#include <HTTPClient.h>
#include <Adafruit_I2CDevice.h>
#include <Adafruit_I2CRegister.h>
#include "Adafruit_MCP9600.h"
#define I2C_ADDRESS (0x67)
const int wdtTimeout = 25000;  //time in ms to trigger the watchdog
hw_timer_t *timer = NULL;

const char* ssid     = "MINDDOT";
const char* password = "88minddot88";
//const char* url      = "http://47.75.204.82/new_temperature";
const char* url      = "http://192.168.111.56:3000/new_temperature";

char* deviceName = "winesphereTemp01";
Adafruit_MCP9600 mcp;

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
  setTxt(60, 50, uptime);
  return uptime_millis;
}

void setTemperature(float _temperature) {
  char temperature[20];
  sprintf(temperature, "%.2f C", _temperature);
  setTxt(60, 30, temperature);
}

float setBattery() {
  char battery[20];
  float voltage = M5.Axp.GetBatVoltage();
  sprintf(battery, "%.3fV", M5.Axp.GetBatVoltage());
  setTxt(60, 60, battery);
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
  setTxt(60, 40, okko);
}

void setState() {
  char state[20];
  IPAddress ip = WiFi.localIP();
  
  if (WiFi.status() == WL_CONNECTED)
    sprintf(state, "%d.%d.%d.%d", ip[0], ip[1], ip[2], ip[3]);
  else
    sprintf(state, "not connected");

  setTxt(60, 20, state);
}

void setup() {
  timer = timerBegin(0, 80, true);                  //timer 0, div 80
  timerAttachInterrupt(timer, &resetModule, true);  //attach callback
  timerAlarmWrite(timer, wdtTimeout * 1000, false); //set time in us
  timerAlarmEnable(timer);       
  
  Serial.begin(115200);
  M5.begin();
  M5.Lcd.setRotation(1);
  M5.Lcd.fillScreen(BLACK);
  M5.Lcd.setTextColor(WHITE);
  M5.Lcd.setTextSize(1);

  setTxt(0, 10, "      ID: ");
  setTxt(0, 20, "   State: ");
  setTxt(0, 30, "    Temp: ");
  setTxt(0, 40, "   OK/KO: ");
  setTxt(0, 50, "  Uptime: ");
  setTxt(0, 60, " Battery: ");
  
  setTxt(60, 10, deviceName);
  setUptime();
  setBattery();

  Wire.begin(33, 32);
  mcp.begin(I2C_ADDRESS);
  mcp.setADCresolution(MCP9600_ADCRESOLUTION_18);
  mcp.setThermocoupleType(MCP9600_TYPE_K);
  mcp.setFilterCoefficient(3);
  mcp.enable(true);
  float temperature = mcp.readThermocouple();
  setTemperature(temperature);

  Serial.println("Try to connect to Wifi");
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    setUptime();
    setBattery();

    /* reset device if we can't connect to the wifi */
    if (millis() > (1000 * 15))
      ESP.restart();

    delay(500);
  }
  setState();
  Serial.println("Connected");
  sendData(temperature);

  /* restart device */
  ESP.restart();
}

bool sendData(float temperature) {
  char json[255];
  HTTPClient http;

  for (int i=0; i<5; i++) {
    sprintf(json, "data={\"thermometer\": \"%s\", \"temperature\": %.3f, \"battery\": %.3f, \"uptime\": %lu}",
                                            deviceName,            temperature,       setBattery(),     setUptime());
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
