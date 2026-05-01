# abhay_app_v2

Welcome to My Flutter Project! This project is built with Flutter and provides a comprehensive example of how to create a mobile application using the Flutter framework.

## Table of Contents

- [Getting Started](#getting-started)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the Project](#running-the-project)
- [Testing](#testing)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

## Prerequisites

Before you begin, ensure you have met the following requirements:

- **Flutter**:
  - [Latest version](https://flutter.dev/docs/get-started/install)
  - Version: 3.27.1
  - Dart: 3.6.0

- **Android Studio**:
  - [Download Android Studio](https://developer.android.com/studio)
  - Version: 36

- **Xcode**:
  - [Download Xcode](https://developer.apple.com/xcode/)
  - Version: 16.2

- **Device or Emulator**:
  - You have a device or emulator to run the application.

## Installation

1. Clone the repository to your local machine:

    ```bash
    git clone https://....
    cd your-project
    ```

2. Install the dependencies:

    ```bash
    flutter pub get
    ```

## Running the Project

1. Connect a device or start an emulator.

2. Run the project:

    ```bash
    flutter run
    ```

3. To run the project on a specific device, use:

    ```bash
    flutter run -d <device_id>
    ```

    You can list all connected devices using:

    ```bash
    flutter devices
    ```

## Testing

This project uses Flutter's built-in testing framework. To run tests, use the following command:

    ```bash
    flutter test
    ```

## Run models

    ```bash
    flutter pub run build_runner build
    ```

    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

## BUILD
    ```bash
    flutter build windows --release
    ```