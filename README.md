Image Classifier App - IT-120 Final Project
A mobile application built with Flutter and Firebase that leverages Machine Learning to identify and classify images in real-time. This project was developed as the final requirement for the IT-120 course.

📌 Project Overview
The app allows users to either capture a photo using the device camera or select one from the gallery. Once an image is provided, the integrated Firebase ML Kit (or TFLite model) processes the visual data and provides a classification label along with a confidence score.

Key Features
Real-time Classification: Quick and accurate image labeling.

Dual Image Source: Support for both Camera and Gallery uploads.

Cloud/On-Device Integration: Powered by Firebase for robust backend support.

User-Friendly UI: Clean and intuitive interface built with Flutter.

📺 Video Demonstration
Watch the full walkthrough of the project and how the app functions in the video below:

Click the image above or here to watch.

🛠 Tech Stack
Frontend: Flutter (Dart)

Backend/ML: Firebase (ML Kit / Firebase Core)

Plugins Used:

image_picker (for camera/gallery access)

firebase_ml_vision or google_ml_kit

firebase_core

🚀 Getting Started
Prerequisites
Flutter SDK installed

Android Studio / VS Code

A Firebase Project set up in the Firebase Console

Installation & Setup
Clone the repository:

Bash

git clone https://github.com/itzJimuel/IT-120-Final-Project-GitHub-repository-Submission.git
Install dependencies:

Bash

flutter pub get
Firebase Configuration:

Add your google-services.json (for Android) to the android/app/ directory.

Add your GoogleService-Info.plist (for iOS) to the ios/Runner/ directory.

Run the app:

Bash

flutter run
🧑‍💻 Author
Jimuel

IT-120 Student

GitHub Profile

📄 License
This project is licensed under the MIT License - see the LICENSE file for details.
