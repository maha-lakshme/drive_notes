# Drive Notes

## Overview

Drive Notes integrates with Google Drive to store your notes as text files inside a dedicated folder. The app leverages Flutter’s Material 3 theming, Riverpod for state management, and Flutter's default Navigator for screen transitions. Although the app offers a theme toggle for light and dark modes, the selected mode is not persisted across app restarts.

## Features

- **Google Drive Integration:**  
  Automatically creates (or reuses) a "DriveNotes" folder in your Google Drive and stores your notes as text files.
- **Note Management:**  
  Create, view, edit, and delete notes.
- **Modern UI (Material 3):**  
  Uses Material 3 with dynamic color schemes generated from seed colors.
- **Light/Dark Theming:**  
  Users can toggle between light and dark modes (theme selection resets upon app restart).
- **State Management:**  
  Riverpod is used for managing state across the app.
- **Navigation:**  
  The app uses Flutter’s default Navigator.
- **Feature-Based Folder Structure:**  
  The project is organized by features (e.g., notes, theming, authentication) rather than by technical layers. This helps improve scalability and maintainability.

## Known Limitations

- **File Metadata vs. Content:**  
  The app lists note metadata (id, name, modifiedTime) initially. Downloading the full note content is done via a separate API call.
- **Single-User Focus:**  
  The current configuration supports personal Drive usage only. Shared drives or collaborative editing require further configuration.
- **Authentication Configuration:**  
  Basic Google API authentication is supported; production use may require more robust error handling and token management.
- **Navigation:**  
  The app uses Flutter’s default Navigator for navigation and does not utilize go_router.
- **Theming:**  
  The theme toggle (light/dark mode) is available, but the user’s selection is not persisted after the app is restarted.

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- A device or emulator to run the app
- A valid Google account to access the Google Drive API

### How to Run the App

1. **Clone the Repository**
   ```bash
   git clone https://github.com/yourusername/DriveNotes.git
   cd drive_notes

2. **Install Dependencies**

  flutter pub get

3. **Run the App**

  flutter run


### Setting Up Google API Credentials

The app uses the Google Drive API to manage note files. Follow these steps to set up your credentials:

1. **Create a Google Cloud Project:**
   - Visit the [Google Cloud Console](https://console.cloud.google.com/).
   - Create a new project or select an existing one.

2. **Enable the Google Drive API:**
   - In the Cloud Console, navigate to **APIs & Services > Library**.
   - Search for **"Google Drive API"** and click **Enable**.

3. **Configure the OAuth Consent Screen:**
   - Navigate to **APIs & Services > OAuth consent screen**.
   - Configure your application details (e.g., app name, support email, etc.).

4. **Create OAuth 2.0 Credentials:**
   - Go to **APIs & Services > Credentials** and click **Create Credentials > OAuth 2.0 Client ID**.
   - Select the application type (Android, iOS, or Web) and provide the required details:
     - **For Android:** Supply your package name and SHA-1 certificate fingerprint.
     - **For iOS:** Set your Bundle Identifier.
   - Download the generated JSON file with your OAuth credentials.

5. **Integrate the Credentials into Your App:**
   - Follow the instructions of your chosen authentication package (such as [google_sign_in](https://pub.dev/packages/google_sign_in)) to integrate these credentials.
   - **For Android:** Place the JSON file in the appropriate directory (typically in the `android/app` folder).
   - **For iOS:** Update your `Info.plist` with the corresponding configuration.

