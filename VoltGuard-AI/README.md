# Volt Guard Lite: AI-Enabled Offline Voltage Stabiliser  


<p align="center">
  <img src="https://github.com/EKKgith4325/PROJECTS_EKK/blob/main/VoltGuard-AI/Prototype.png" alt="Prototype" width="475" height="475" style="border-radius:10px; margin:10px;">
  <img src="https://github.com/EKKgith4325/PROJECTS_EKK/blob/main/VoltGuard-AI/1_VoltGuard%20Lite%20CFD.drawio.png" alt="Control and Data Flow" width="400" height="400" style="border-radius:10px; margin:10px;">
</p>

![ESP32](https://img.shields.io/badge/Hardware-ESP32-blue)
![TinyML](https://img.shields.io/badge/ML-TinyML-green)
![License](https://img.shields.io/badge/License-MIT-yellow)


---

## Overview  
Volt Guard Lite is an offline, AI-enabled, solid-state voltage stabiliser engineered for Indian households, particularly in low-connectivity zones.  
It combines TinyML-based voltage forecasting, local data logging, and solid-state switching to protect appliances from both predictable and sudden anomalies.  
The system aims to replace traditional reactive stabilisers with a predictive and adaptive offline solution.

---

## Problem Statement  
India’s household appliances are designed for 230 V ±10% (≈207–253 V), yet semi-urban and rural regions often face extreme swings of ±30–40%, transient spikes, and brownouts.  
These anomalies accelerate appliance wear, waste energy, and cause costly failures.  
Existing stabilisers are reactive, rely on cloud connectivity, and have slow relay response times (20–40 ms).  
Volt Guard Lite addresses this by offering:  
1. Predictive voltage fluctuation detection using on-device learning.  
2. Offline operation without cloud dependency.  
3. Real-time monitoring and manual control via Bluetooth.  
4. Sub-millisecond switching using SSR/IGBT modules.  
5. Scalability across different load ranges.

---

## Key Features  
- Predictive AI protection using TinyML on ESP32.  
- Offline smart operation with Bluetooth monitoring.  
- Solid-state speed through SSR/IGBT modules.  
- PostgreSQL database for local voltage/current logging.  
- Autoencoder-based anomaly detection for voltage instability.  
- Configurable delay timers and staged recovery logic.  
- Manual override and audible alerts for user safety.  

---

## Technology Stack  

### Hardware  
- ESP32 microcontroller  
- Raspberry Pi 3 B (for data processing and model training)  
- HLW8012 voltage/current sensing IC  
- SSR/IGBT switching stage  
- Surge and thermal protection circuits  

### Software  
- TinyML (TensorFlow Lite for Microcontrollers)  
- Python (Edge ML pipeline on Raspberry Pi)  
- PostgreSQL database  
- MQTT for data communication  
- Bluetooth mobile app (MIT App Inventor / Flutter)

---

## System Architecture and Operation  

### Core Components  
- **Sensing Module:** HLW8012 IC provides continuous voltage and current measurements.  
- **Control Unit:** ESP32 performs sensor sampling, TinyML inference, and control logic.  
- **Edge Compute Node:** Raspberry Pi 3 B manages local storage, retraining, and logging.  
- **Database:** PostgreSQL stores historical voltage/current logs for pattern analysis.  
- **Switching Stage:** SSR/IGBT modules handle load switching with microsecond response.  
- **User Interface:** Bluetooth mobile app for real-time monitoring and control.

### Data Flow  
1. ESP32 reads voltage/current data at 2–5 Hz.  
2. Data is sent to Raspberry Pi via MQTT.  
3. Raspberry Pi stores readings in a 24-hour circular buffer.  
4. Features are extracted (mean, standard deviation, deltas).  
5. Autoencoder model detects anomalies through reconstruction error.  
6. ESP32 performs switching or alerts based on prediction and thresholds.

---

## Machine Learning Pipeline  

- **Model Type:** Autoencoder neural network trained on normal voltage/current data.  
- **Input:** 24-hour window with six features per time step.  
- **Architecture:** Encoder-decoder with 64-32-16 latent dimensions and 8-neuron bottleneck.  
- **Loss Function:** Mean Squared Error (MSE).  
- **Optimizer:** Adam (LR=0.001).  
- **Anomaly Threshold:** 95th percentile of MSE on normal data.  
- **Metrics:** Precision, Recall, F1 score for validation.  
- **Deployment:** Quantized (int8) TensorFlow Lite model on Raspberry Pi.  
- **Inference Time:** 50–80 ms per 24-hour window.  

---

## Hardware Design  

- **Power Module:** AC mains through fuse, MOV, and HLK-PM01 AC–DC converter.  
- **Sensing Circuit:** HLW8012 measures voltage/current via resistor divider and shunt network.  
- **Control Unit:** ESP32 with transistor drivers, buzzer alerts, and thermal monitoring.  
- **Switching Stage:** Opto-isolated SSR with snubber and delay logic.  
- **Safety Features:**  
  - Over/Under Voltage Cutoff (180 V–270 V).  
  - Programmable restart delay for motors.  
  - Temperature-based shutdown.  
  - Audible fault indication.  

---

## Software and Database Process  

1. ESP32 collects data and sends it to Raspberry Pi via MQTT.  
2. Pi stores 24-hour circular buffer of data in PostgreSQL.  
3. Rolling statistics and deltas are computed every 60 seconds.  
4. Autoencoder processes input and computes reconstruction error.  
5. If error exceeds threshold, Pi flags an anomaly to ESP32.  
6. ESP32 validates locally and triggers protective actions.

---

## User Interface  

- Bluetooth application built using MIT App Inventor or Flutter.  
- Provides real-time voltage/current visualisation, alerts, and manual control.  
- Operates entirely offline.  
- Allows configuration changes, delay settings, and log export.


## Connect and Collaboration  
For professional collaborations, technical discussions, or project partnerships, feel free to connect on LinkedIn:  
**[LinkedIn Profile](https://www.linkedin.com/in/ek-k-k-y55y/)**  
