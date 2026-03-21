# 🔐 Password Manager

A robust, secure, and intuitive password manager application built entirely with Flutter.

---

## 📑 Table of Contents
- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation & Setup](#-installation--setup)
  - [Automated Setup (Windows)](#automated-setup-windows)
  - [Manual Setup](#manual-setup)
- [Running the App](#-running-the-app)
- [Building for Production (APK)](#-building-for-production-release)
- [Project Architecture](#-project-architecture)
- [AI Environment Setup Prompt](#-ai-environment-setup-prompt)

---

## ✨ Features
- **Secure Storage**: Safely store your usernames and passwords.
- **Strong Generator**: Generate highly secure, random passwords.
- **Cross-Platform**: Built natively with Flutter for fluid multi-platform support.
- **Modern UI**: Clean, responsive, and beautiful user interface.
- **Local Enclave**: All passwords stay strictly encrypted on your device.

---

## 🛠 Tech Stack
- **Framework**: Flutter (Dart)
- **Target OS**: Android (Primary Support Profiled), iOS, Web, Desktop

---

## ⚙️ Prerequisites
Before building the project, ensure you have the following installed:
1. **Flutter SDK**: Ensure `flutter` is added to your system `$PATH` and accessible globally.
2. **Java Development Kit (JDK) 17**: Required specifically for Android compilation and grade builds.
3. **Android SDK Command-line Tools**: For downloading Android platform dependencies, build tools, and establishing SDK licenses.

---

## 🚀 Installation & Setup

### Automated Setup (Windows)
If you are running on a Windows environment, you can fully automate the installation of JDK 17, Android SDK tools, and the build process using the bundled initialization script located in the parent directory.

1. Open PowerShell as an administrator.
2. Navigate to the root workspace directory (one level above this project folder):
   ```powershell
   cd \path\to\workspace
   ```
3. Execute the setup script:
   ```powershell
   .\setup_and_build.ps1
   ```
> **Note:** The script effortlessly downloads dependencies into an isolated `android_deps` folder, accepts Android SDK licenses seamlessly, configures the `flutter` CLI paths globally, and initiates an immediate APK build.

---

### Manual Setup
1. **Clone the repository**:
   ```bash
   git clone https://github.com/infocodersclick-sketch/PSManager.git
   cd PSManager/password_manager
   ```

2. **Fetch Flutter Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Environment Configurations**:
   Run the Flutter doctor utility to confirm your Java and Android SDK toolchains are correctly configured.
   ```bash
   flutter doctor -v
   ```

---

## 💻 Running the App

1. Connect your physical Android/iOS device via USB or start a virtual emulator.
2. To run the app in debug mode with hot-reload and hot-restart capabilities:
   ```bash
   flutter run
   ```

---

## 📦 Building for Production (Release)

To generate a standalone Release APK that you can distribute and install on any Android device without needing a development kit:
```bash
flutter build apk --release
```
The compiled, signed APK will be successfully generated at the following relative path:
`build\app\outputs\flutter-apk\app-release.apk`

---

## 🏛 Project Architecture (Standard Layout)
- `lib/main.dart` - Bootstraps the app and initializes application states.
- `lib/screens/` - Contains major UI flow screens (Home Screen, Detail Forms, Settings).
- `lib/widgets/` - Reusable granular UI components, cards, and structured layouts.
- `lib/theme/` - Application-wide styling variables, definitions, and color pallets configuration.
- `pubspec.yaml` - Standardized dependency and global asset management.

---

## 🤖 AI Environment Setup Prompt
If you are utilizing an Autonomous AI Coding Assistant (e.g., Claude, ChatGPT, Gemini, etc.) to bootstrap your local development workspace entirely from scratch, simply copy and deploy the exact prompt sequence below to have it execute the necessary Bash/PowerShell commands iteratively.

> **AI Prompt to Setup Workspace & Build Project:**
> 
> "Please set up the Android development environment for this Flutter project so we can compile it natively. First, create a directory named `android_deps` at the workspace root. Download OpenJDK 17 and the latest Android SDK Command-line Tools securely into this directory and extract them into their respective nested folders (e.g. `jdk` and `cmdline-tools`). Export the respective temporary environment variables for this terminal session: `$env:JAVA_HOME` and `$env:ANDROID_HOME`, actively pointing to the extracted folders. Append both newly configured `\bin` directories to the Windows system `$env:PATH`. Once functionally mapped, automatically accept all pertinent Android SDK developer licenses utilizing `sdkmanager.bat --licenses` (you can programmatically pipe 'y' to it). Following that, install the required distinct Android platform (`android-34`) and its corresponding build-tools (`34.0.0`) by firing the `sdkmanager`. Finally, invoke `flutter config` to dynamically set `--android-sdk` and `--jdk-dir` bindings mapping to the newly installed remote paths, modify the current working directory to seamlessly enter `password_manager`, and execute a terminal `flutter build apk --release` instance to forcefully compile the app entirely from scratch."
