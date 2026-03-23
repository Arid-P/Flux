# Android Emulator Setup Guide

Since the Android SDK is currently not detected on your system, you'll need to follow these steps to set up an emulator.

## 1. Install Android Studio (Recommended)
The easiest way to get the Android SDK and manage emulators is through Android Studio.
1. Download [Android Studio](https://developer.android.com/studio).
2. Run the installer and follow the "Standard" setup.
3. Once installed, open Android Studio and complete the **Android Studio Setup Wizard** to download the latest Android SDK, SDK Build-Tools, and SDK Platform-Tools.

## 2. Configure Flutter to use the SDK
After Installing Android Studio, you need to tell Flutter where the SDK is located.
1. Open a terminal and run:
   ```powershell
   flutter config --android-sdk "C:\Users\YourUsername\AppData\Local\Android\Sdk"
   ```
   *(Replace `YourUsername` with your actual Windows username)*
2. Run `flutter doctor` again to ensure the Android toolchain is detected. You may need to run `flutter doctor --android-licenses` to accept licenses.

## 3. Create an Emulator (AVD)
1. In Android Studio, go to **Tools > Device Manager**.
2. Click **Create Device**.
3. Select a phone model (e.g., Pixel 7) and click **Next**.
4. Choose a System Image (e.g., **API 34** or latest stable) and click **Download** next to it if needed.
5. Click **Next** and finally **Finish**.

## 4. Run the Emulator and App
1. To start the emulator from the terminal:
   ```powershell
   flutter emulators --launch <emulator_id>
   ```
   *(To see the ID, run `flutter emulators`)*
2. Once the emulator is running, launch the app:
   ```powershell
   cd fluxdone
   flutter run
   ```

## Alternative: Testing on a Physical Device
If your computer has limited RAM, testing on a physical Android phone is often faster.
1. Enable **Developer Options** and **USB Debugging** on your phone.
2. Connect it via USB.
3. Run `flutter devices` to confirm it's detected.
4. Run `flutter run`.
