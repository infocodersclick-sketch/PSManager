# Password Manager

A robust and secure password manager application built using Flutter. This application helps users store, manage, and generate strong passwords easily and safely.

## Requirements

- **Flutter SDK**: Installed and accessible in your system.
- **Java Development Kit (JDK) 17**: Required for building the Android application.
- **Android SDK**: Command-line tools, build tools (version 34.0.0), and platforms.

## Setup and Run Instructions

### Automated Setup (Windows PowerShell)

There is a bundled PowerShell script (`setup_and_build.ps1`) located in the root workspace (one directory above `password_manager`) that fully automates the installation of OpenJDK 17, the Android SDK command-line tools, SDK configurations, and finally compiles a release APK.

To use the automated build:
1. Open a PowerShell terminal.
2. Navigate to the root folder housing the script.
3. Run the script:
   ```powershell
   .\setup_and_build.ps1
   ```
4. The script will automatically download dependencies to an `android_deps` folder, configure Flutter paths, and build the APK. The generated APK will be available at:
   `build\app\outputs\flutter-apk\app-release.apk`

### Manual Setup and Execution

If you prefer to set up manually or you are managing dependencies yourself:
1. Clone or download this project and open a terminal in the `password_manager` directory.
2. Run `flutter pub get` to install Flutter dependencies.
3. Connect your Android device or start an emulator.
4. Run the application locally for testing and debugging:
   ```bash
   flutter run
   ```

To build a release APK manually, execute:
```bash
flutter build apk --release
```

---

## AI Agent Setup Setup Prompt

If you are using an AI coding assistant to configure the workspace for you from scratch, you can copy and provide the following prompt to have it automatically handle all installations and configuration necessary to run this project:

> **AI Prompt to Setup Dependencies and Workspace:**
> "Please set up the Android development environment for this Flutter project so we can compile it. First, create a directory named `android_deps`. Download OpenJDK 17 and the latest Android SDK Command-line Tools into this directory and extract them into their respective folders (`jdk` and `cmdline-tools`). Set the temporary environment variables for this terminal session: `$env:JAVA_HOME` and `$env:ANDROID_HOME`, pointing to the extracted folders. Add their `\bin` directories to the Windows system `$env:PATH`. Once mapped, automatically accept all Android SDK licenses using `sdkmanager.bat --licenses` (you can pipe 'y' to it). Then, install the Android platform (`android-34`) and build-tools (`34.0.0`) using the `sdkmanager`. Finally, run `flutter config` to dynamically set `--android-sdk` and `--jdk-dir` to the newly installed paths, change the directory to `password_manager`, and execute `flutter build apk --release` to compile the app completely."
