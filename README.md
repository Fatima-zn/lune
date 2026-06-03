# Lune 🌙

**Your Podcast Universe.**

Lune is a Flutter podcast application designed to make discovering, listening to, and managing podcasts more convenient. It combines podcast search and recommendations with personalized listening experiences, library management, and listening statistics.

## Features

### Discover

- Search for podcasts and episodes.
- Explore trending podcasts and browse by genre.
- Discover related episodes through personalized recommendations.
- Access podcast information through the Listen Notes API.

### Listen

- Play podcast episodes with background playback support.
- Control playback through system notifications and lock-screen controls.
- Resume recently played episodes.

### Personalize

- Enjoy a home screen with personalized greetings.
- Track listening activity and monthly listening goals.
- View listening statistics through an interactive dashboard.

### Manage Your Library

- Save favorite podcasts and episodes.
- Synchronize listening progress and library data through Firebase.
- Access cached data for improved availability.

### Security

- User authentication with Firebase Authentication.
- Email verification during account registration.
- Biometric authentication for protected access.
- Biometric confirmation for removing items from the library.

## Tech Stack

| Technology | Purpose |
| --- | --- |
| Flutter | Application framework |
| Dart | Programming language |
| Riverpod | State management |
| GoRouter | Navigation and routing |
| Firebase Authentication | User authentication |
| Cloud Firestore | Cloud data storage and synchronization |
| Listen Notes API | Podcast search and discovery |
| Just Audio | Audio playback |

## Architecture

Lune follows a layered architecture that separates presentation, application logic, and data access.

- **Presentation layer:** User interface and screens.
- **Domain layer:** Application logic and core operations.
- **Data layer:** API integration, data parsing, and persistence.

The project uses a feature-oriented structure to organize functionality, including authentication, playback, and library management.

Riverpod Notifiers manage application state, while custom data parsers and error handling help accommodate inconsistent API responses. Local caching and cloud synchronization support data persistence and availability.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK compatible with the project
- Android development environment
- A Listen Notes API key
- Firebase project configuration

### Installation

1. Clone the repository:

    ```bash
        git clone https://github.com/Fatima-zn/lune.git
        cd lune
    ```

2. Install dependencies:

    ```bash
        flutter pub get
    ```

3. Configure the Listen Notes API and Firebase credentials required by the application.

4. Connect an Android device or start an Android emulator.

5. Run the application:

    ```bash
        flutter run
    ```

**Note:** Follow the project's existing configuration structure when supplying API credentials and Firebase settings. Do not commit private credentials or signing keys to the repository.
