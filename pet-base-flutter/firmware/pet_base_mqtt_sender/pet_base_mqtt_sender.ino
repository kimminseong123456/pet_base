#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>

// PET BASE ESP32 MQTT sender skeleton
// 실제 부품 연결 후 검증 필요:
// - MAX30102 심박 측정
// - TMP117 표면온 기반 체온 추정
// - BMI270 움직임/stable 판단 및 호흡 추정
// - SQI 계산
// 현재 코드는 실제 센서값 대신 mock 값을 사용한다.

const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

const char* MQTT_HOST = "192.168.0.10";
const int MQTT_PORT = 1883;

const char* DEVICE_ID = "dog-001";
const int DOG_ID = 1;

WiFiClient espClient;
PubSubClient mqttClient(espClient);

unsigned long lastPublishMs = 0;
const unsigned long PUBLISH_INTERVAL_MS = 10000;

int scenarioIndex = 0;

String vitalsTopic() {
  return String("/device/") + DEVICE_ID + "/vitals";
}

String eventTopic() {
  return String("/device/") + DEVICE_ID + "/event";
}

void connectWifi() {
  if (WiFi.status() == WL_CONNECTED) {
    return;
  }

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
}

void reconnectWifiIfNeeded() {
  // Wi-Fi 재연결 의사코드
  // 1. WiFi.status() 확인
  // 2. 연결이 끊겼으면 WiFi.disconnect() 후 WiFi.begin()
  // 3. 일정 횟수 실패하면 센서 측정은 유지하되 publish는 보류
  // 4. 재연결 후 다음 10초 주기에 publish 재개
  if (WiFi.status() != WL_CONNECTED) {
    WiFi.disconnect();
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - start < 10000) {
      delay(500);
    }
  }
}

void connectMqtt() {
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);

  while (!mqttClient.connected()) {
    String clientId = String("petbase-") + DEVICE_ID;
    if (mqttClient.connect(clientId.c_str())) {
      break;
    }
    delay(1000);
  }
}

void reconnectMqttIfNeeded() {
  if (!mqttClient.connected()) {
    connectMqtt();
  }
}

void fillMockVitals(JsonDocument& doc) {
  // FastAPI HTTP payload와 같은 필드 구조를 유지한다.
  // MQTT subscriber 연동 시 이 payload를 그대로 검증/판독하면 된다.
  doc["ts"] = "2026-06-03T10:20:00Z";
  doc["device_id"] = DEVICE_ID;
  doc["dog_id"] = DOG_ID;
  doc["motion_state"] = "stable";
  doc["sqi_ppg"] = 0.91;
  doc["sqi_rr"] = 0.88;
  doc["sqi_temp"] = 0.77;
  doc["invalid_reason"] = nullptr;
  doc["battery_pct"] = 82;
  doc["red_flag"] = false;

  int mode = scenarioIndex % 6;
  scenarioIndex++;

  if (mode == 0) {
    doc["hr_bpm"] = 118;
    doc["rr_bpm"] = 24;
    doc["temp_est_c"] = 38.4;
  } else if (mode == 1) {
    doc["hr_bpm"] = 148;
    doc["rr_bpm"] = 25;
    doc["temp_est_c"] = 39.15;
  } else if (mode == 2) {
    doc["hr_bpm"] = 152;
    doc["rr_bpm"] = 34;
    doc["temp_est_c"] = 39.35;
  } else if (mode == 3) {
    doc["hr_bpm"] = 166;
    doc["rr_bpm"] = 36;
    doc["temp_est_c"] = 40.05;
  } else if (mode == 4) {
    doc["hr_bpm"] = 186;
    doc["rr_bpm"] = 54;
    doc["temp_est_c"] = 40.7;
    doc["red_flag"] = true;
  } else {
    doc["hr_bpm"] = 118;
    doc["rr_bpm"] = 24;
    doc["temp_est_c"] = 38.4;
    doc["motion_state"] = "moving";
    doc["invalid_reason"] = "motion";
  }
}

void publishVitals() {
  StaticJsonDocument<512> doc;
  fillMockVitals(doc);

  char payload[512];
  serializeJson(doc, payload, sizeof(payload));

  mqttClient.publish(vitalsTopic().c_str(), payload);

  bool redFlag = doc["red_flag"] | false;
  const char* invalidReason = doc["invalid_reason"];

  if (redFlag || invalidReason != nullptr) {
    StaticJsonDocument<256> eventDoc;
    eventDoc["device_id"] = DEVICE_ID;
    eventDoc["dog_id"] = DOG_ID;
    eventDoc["event_type"] = redFlag ? "red_flag" : "invalid";
    eventDoc["invalid_reason"] = invalidReason;

    char eventPayload[256];
    serializeJson(eventDoc, eventPayload, sizeof(eventPayload));
    mqttClient.publish(eventTopic().c_str(), eventPayload);
  }
}

void setup() {
  Serial.begin(115200);
  connectWifi();
  connectMqtt();
}

void loop() {
  reconnectWifiIfNeeded();
  reconnectMqttIfNeeded();
  mqttClient.loop();

  unsigned long now = millis();
  if (now - lastPublishMs >= PUBLISH_INTERVAL_MS) {
    lastPublishMs = now;
    publishVitals();
  }
}
