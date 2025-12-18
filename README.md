This README provides a comprehensive overview of your Flutter and Firebase image classification project, based on the details from your video demonstration.

---

# 🚗 Flutter Image Classification App

A mobile application built with **Flutter** and **Firebase** that classifies common car brands found in the Philippines. The app leverages on-device machine learning to provide real-time, privacy-focused image recognition.

## 📌 Project Overview

This project is an image classifier designed to identify 10 different classes of car brands (including Toyota, Nissan, Honda, Mitsubishi, and others). It allows users to capture images via the camera or select them from the gallery to receive instant classification results with a high degree of accuracy.

## 🚀 Key Features

* **Multi-Class Classification:** Specifically trained to recognize the most popular car brands in the Philippine market [[00:21](http://www.youtube.com/watch?v=GtmuSy8X12s&t=21)].
* **Dual Input Modes:** Supports both real-time **Camera capture** and **Gallery selection** for image analysis [[01:29](http://www.youtube.com/watch?v=GtmuSy8X12s&t=89)].
* **High Accuracy:** Demonstrated performance reaching up to **99.5% confidence** in classification tests [[01:13](http://www.youtube.com/watch?v=GtmuSy8X12s&t=73)].
* **On-Device Inference:** Uses local model processing instead of cloud-based APIs to ensure:
* **Data Privacy:** Images are processed locally and never uploaded to a server [[03:39](http://www.youtube.com/watch?v=GtmuSy8X12s&t=219)].
* **Low Latency:** Instant results regardless of network connectivity [[03:49](http://www.youtube.com/watch?v=GtmuSy8X12s&t=229)].


* **Automated Logging:** Classification results, including labels, confidence scores, and system-generated timestamps, are accurately recorded in the database through a centralized service layer [[02:40](http://www.youtube.com/watch?v=GtmuSy8X12s&t=160)].

## 🛠️ Tech Stack

* **Frontend:** Flutter (Dart)
* **Backend/Database:** Firebase (used for reliable auditing and data storage [[03:03](http://www.youtube.com/watch?v=GtmuSy8X12s&t=183)])
* **Machine Learning:** On-device ML Model inference

## 📋 System Design & Reliability

To ensure the integrity of the classification logs, the app implements several safeguards:

1. **Direct Recording:** Results are pulled directly from the model to the database to prevent manual modification [[02:40](http://www.youtube.com/watch?v=GtmuSy8X12s&t=160)].
2. **Validation:** Data is validated for completeness and expected ranges before being saved [[03:03](http://www.youtube.com/watch?v=GtmuSy8X12s&t=183)].
3. **Schema Enforcement:** A centralized service layer handles database writes to prevent duplicates and maintain a consistent schema [[03:15](http://www.youtube.com/watch?v=GtmuSy8X12s&t=195)].

## 🔮 Future Enhancements

If given more development time, the following features are planned for future updates [[04:09](http://www.youtube.com/watch?v=GtmuSy8X12s&t=249)]:

* **Model Retraining:** Optimizing accuracy using a wider variety of real-world data.
* **Offline Synchronization:** Adding background sync capabilities for offline detection logs.
* **Batch Processing:** Support for classifying multiple images simultaneously.
* **Analytics Dashboard:** A monitoring interface to track model performance and error rates.

## 👤 Author

**Jimuel Amuto**
Full Video link below:
https://www.youtube.com/watch?v=GtmuSy8X12s&t=7s


