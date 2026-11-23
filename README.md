
<div align="center">

# TeamUp

### Find Your Team. Build Something Great.

An offline-first mobile application that helps university students discover compatible teammates, organize project teams, and collaborate efficiently.

<p>
  <img src="https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Material_3-6750A4?style=flat&logo=materialdesign&logoColor=white" />
  <img src="https://img.shields.io/badge/Riverpod-00A67E?style=flat" />
  <img src="https://img.shields.io/badge/Hive-FFB300?style=flat" />
</p>

</div>

---

## Overview

TeamUp is an offline-first mobile application designed to help university students find suitable teammates for academic projects.

Students can create profiles highlighting their skills, interests, and availability, discover compatible teammates, send team requests, and organize collaborative projects within the application.

The application focuses on simplifying team formation while providing a structured environment for managing teams, tasks, and communication.

---

## Features

### Profile Management

- Create and customize user profiles
- Manage personal information
- Add skills and interests
- Update profile information
- Select profile avatars

### Teammate Discovery

- Discover potential teammates
- Match users based on skills and interests
- Filter potential teammates
- View compatibility information
- Identify complementary skill sets

### Team Management

- Create and manage project teams
- View team members
- Manage team membership
- Identify skill gaps within a team

### Collaboration

- Team chat
- Discuss project ideas with teammates
- Task management
- Project checklists
- Organize collaborative work

### Application Experience

- Offline-first functionality
- Local data persistence
- Light and dark themes
- Responsive layouts
- Portrait and landscape support

---

## Matching System

TeamUp uses a deterministic matching approach to help students discover suitable teammates.

The matching process considers relevant profile information such as:

- Skills
- Interests
- Project requirements
- Skill compatibility

The system provides explainable matching results rather than relying on an opaque recommendation process.

---

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile development |
| Dart | Programming language |
| Material 3 | UI design system |
| Riverpod | State management |
| Hive | Local data persistence |
| GoRouter | Application navigation |
| SharedPreferences | Persistent application preferences |

---

## Architecture

TeamUp is designed around a modular application structure that separates user interface, state management, application logic, and local data handling.

The architecture supports maintainability and makes it easier to extend the application's functionality.

---

## Offline-First Design

TeamUp is designed to operate locally without requiring an internet connection or remote backend service.

Application data and preferences are stored locally, allowing users to access the core application functionality offline.

**Current implementation:** Local storage and device-based functionality.

---

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical Android device

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/SaadNafees007/TeamUp-Flutter.git
```

**2. Navigate to the project directory**

```bash
cd TeamUp-Flutter
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Run the application**

```bash
flutter run
```

---

## Development

Format the code:

```bash
dart format .
```

Analyze the project:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

---

## Future Improvements

- Cloud-based synchronization
- Remote team collaboration
- Backend-powered user discovery
- Notifications for team requests
- Advanced matching algorithms
- Expanded project management capabilities

---

## Author

<div align="center">

**Saad Nafees**

Software Engineering Student  
COMSATS University Islamabad

<a href="https://github.com/SaadNafees007">
GitHub
</a>
&nbsp; · &nbsp;
<a href="https://www.linkedin.com/in/saadnafees007">
LinkedIn
</a>

</div>

---

<div align="center">

*Designed to help students connect, collaborate, and build better projects together.*

</div>
