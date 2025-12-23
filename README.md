# 🌦️ Hyperlocal IoT Weather Station

> A complete end-to-end IoT solution bridging the gap between generic city forecasts and specific microclimate data.

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![ESP32](https://img.shields.io/badge/ESP32-Hardware-red?style=for-the-badge)
![Python](https://img.shields.io/badge/Python-Backend-yellow?style=for-the-badge&logo=python&logoColor=white)

## 📖 Overview

Standard weather apps give you data for a whole city, which can be kilometers away from your actual location. The **Hyperlocal IoT Weather Station** solves this "data gap" by providing precise, real-time environmental data for your specific garden, farm, or balcony.

This project combines a custom **Flutter Mobile App** with an **ESP32-based Sensor Node** to monitor:
* Temperature & Humidity (BME280)
* Soil Moisture levels
* UV Index (VEML6070)
* Air Quality (MQ-135)
* Wind Speed & Direction
* Exact Location (GPS NEO-6M)

## ✨ Key Features

* **Interactive Splash Screen:** Custom "Power On" UI with animated transitions (replacing standard loading spinners).
* **Hyperlocal Dashboard:** High-fidelity UI with radial gauges and data cards for visualizing local sensor data.
* **Global Weather Integration:** Fetches live weather data from OpenWeatherMap API based on the user's real-time GPS location.
* **Hardware Integration:** designed for ESP32 LoRa/Wi-Fi modules with a comprehensive sensor array.
* **Robust Architecture:** Separates data sensing (Hardware), data processing (Backend), and data visualization (Frontend).

## 📱 App Screenshots

| Splash Screen | Main Dashboard | Global Weather |
|:---:|:---:|:---:|
| ![!](https://github.com/user-attachments/assets/20c63026-2bff-42bb-a356-2cc7491330bc)
 | ![2](https://github.com/user-attachments/assets/0a94e935-8191-4a8f-a0c5-64c6ac38a796)
 | ![3](https://github.com/user-attachments/assets/31e2a5c1-1618-456c-8f21-eda0397a29ca)
 |
*(Note: Please upload screenshots to a `screenshots` folder to view them here)*

## 🏗️ System Architecture

The system operates on a three-tier architecture:

```mermaid
graph TD
    subgraph Hardware Node
        A[ESP32] --> Sensors[BME280, GPS, Soil, UV, Wind]
    end
    
    subgraph Mobile App
        B[Flutter App] -- Mock/Real Data --> C[Dashboard UI]
        B -- GPS Coordinates --> D[OpenWeatherMap API]
        D -- JSON Data --> E[Global Weather UI]
    end
    
    Sensors --> A
