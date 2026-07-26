<div align="center">

  # 📌 Taskatii (تاسكاتي)
  ### *Your Ultimate Offline-First Productivity & Task Management Companion*

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Hive](https://img.shields.io/badge/HiveDB-FF6F00?style=for-the-badge&logo=hive&logoColor=white)](https://pub.dev/packages/hive)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

  <p align="center">
    <b>Taskatii</b> is a modern, fast, and beautifully designed offline task management application built with <b>Flutter</b>. Powered by <b>Hive local storage</b>, it features a live Pomodoro timer, smart task alarms with 6-hour pre-notification, an interactive month-grid calendar with task indicators, optional per-task alarms, and complete data privacy — no sign-in required.
  </p>

</div>

---

## ✨ Key Features

### 🚀 Instant 100% Offline Access (No Sign-In Required)
- **Zero Friction**: Launch straight into your tasks without sign-up forms, logins, or cloud delays.
- **Permanent Local Storage**: Profile data (names & images) are safely stored in the device's persistent application directory.
- **4-Second Animated Splash Screen**: A full-screen Lottie animation greets you on launch before navigating to your tasks.

### 📋 Task & Sub-task Checklist Management
- **Multi-Task Concurrency**: Add multiple tasks at identical dates or times without conflict — powered by unique microsecond IDs.
- **Sub-tasks Checklist**: Break down complex tasks into smaller steps with progress indicators (`X/Y Done`).
- **Priority & Categories**: Priority color-coding (**High 🔴**, **Medium 🟡**, **Low 🟢**) and category tagging (Work, Personal, Study, Health, Shopping, General).
- **Completed Task Highlighting**: Completed tasks display in a distinct **Emerald Green** color to celebrate progress visually.
- **Chronological Sorting**: Smart task sorting by start time — pending tasks first, completed last.
- **Timed Undo on Delete**: Deleting a task shows a floating Undo snackbar that auto-dismisses after **2 seconds**, preventing accidental lingering UI.

### ⏱️ Focus Mode (Pomodoro Timer) & Live Notifications
- **Pomodoro Timer**: Customizable focus timer presets (15, 25, 45 mins) with optional task attachment.
- **Live Notification Chronometer**: Displays a real-time countdown timer in the phone's notification status bar while the app runs in the background.
- **Tap-to-Navigate**: Tapping the live timer notification navigates directly to the Focus (Pomodoro) screen inside the app.

### 🔔 Smart Alarms & Task Notifications
- **Optional Per-Task Alarms**: Alarms are opt-in per task — tasks only trigger notifications when you explicitly enable the alarm toggle.
- **6-Hour Pre-Notification**: For tasks scheduled days in advance, the notification triggers **6 hours before** the task's start time, keeping your notification bar clean.
- **Tap-to-Navigate**: Tapping a task notification navigates directly to that task's details inside the app.
- **BigTextStyle Formatting**: Highly visible, large bold text and timestamps inside Android notifications shade.

### 📅 Interactive Month-Grid Calendar
- **Full Month Grid**: A complete month view with navigation arrows (prev/next month) replaces the old horizontal date strip.
- **Task Dot Indicators**: Days that contain tasks display a colored dot **directly inside the calendar cell** for instant visual overview.
- **Today Highlight**: Today's date is distinctly highlighted with a border ring even when not selected.
- **Tap Any Day**: Tapping a day in the grid immediately loads and displays all tasks for that date below.
- **Productivity Streak Tracker**: Instant overall completion statistics badge in the home header (`🔥 X/Y Done`).

### 👤 Profile & Personalization
- **Avatar Full-Image Preview**: Long-pressing the profile picture shows the **full image** (uncropped) in a modal with pinch-to-zoom support.
- **Instant Avatar Updates**: Changing your profile picture immediately clears Flutter's image cache and updates every avatar across the app.
- **Unique File-per-Upload**: Each new profile photo is saved under a unique timestamped filename; the old file is automatically cleaned up.
- **Seamless Dark / Light Theme**: Built-in Dark Mode toggle in profile settings, persisted across app restarts.

---

## 🛠️ Tech Stack & Architecture

| Layer | Technology |
|---|---|
| **Framework** | [Flutter SDK](https://flutter.dev/) (Dart 3.x) |
| **Local Database** | [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter) |
| **Notifications** | [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |
| **Image Picker** | [image_picker](https://pub.dev/packages/image_picker) |
| **Animations** | [lottie](https://pub.dev/packages/lottie) |
| **Storage Path** | [path_provider](https://pub.dev/packages/path_provider) |
| **Fonts & UI** | `google_fonts`, `gap`, `intl` |
| **Architecture** | Clean Feature-First Architecture |

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── functions/         # Navigation helpers
│   ├── models/            # TaskModel & Hive Adapters
│   ├── services/          # LocalStorage (Hive) & NotificationService
│   ├── utils/             # Colors, TextStyles, App Themes
│   └── widgets/           # Reusable widgets (UserAvatar, TaskItem, CustomButton)
└── features/
    ├── add_task/          # Add & Edit Task view (with alarm toggle)
    ├── analytics/         # Productivity Analytics view
    ├── calendar/          # Interactive Month-Grid Calendar & Schedule view
    ├── focus/             # Focus / Pomodoro view with Live Notification
    ├── home/              # Dashboard, Search, Streak stats
    ├── intro/             # Splash (4s Lottie) & Onboarding views
    ├── main_layout/       # Bottom Navigation Bar Container
    └── profile/           # Profile, Avatar, Dark Mode settings
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.4.4`)
- Android Studio / VS Code
- An Android / iOS device or Emulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Sadoun90/taskatii.git
   cd taskatii
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
   Crafted with ❤️ by <b><a href="https://github.com/Sadoun90">Sadoun</a></b>
</div>
