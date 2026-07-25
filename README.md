<div align="center">

  <img src="assets/logo.json" width="120" height="120" alt="Taskatii Logo" />

  # 🚀 Taskatii (تأسكاتي)
  ### *Your Ultimate Productivity & Task Management Companion*

  [![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev/)
  [![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com/)
  [![Hive](https://img.shields.io/badge/HiveDB-FF6F00?style=for-the-badge&logo=hive&logoColor=white)](https://pub.dev/packages/hive)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](LICENSE)

  <p align="center">
    <b>Taskatii</b> is a modern, beautifully designed task management and productivity application built with <b>Flutter</b>. It combines offline-first local storage via <b>Hive</b> with cloud features via <b>Supabase</b>, providing a seamless task tracking, focus timer, and reminder experience.
  </p>

</div>

---

## ✨ Features

### 🔐 Authentication & Guest Mode
- **Email & Password Authentication**: Powered by Supabase Auth with automatic offline fallback.
- **Guest Mode**: Full offline usability for users who prefer not to sign up.
- **Remember Me**: Secure local caching of login state for instant app access.

### 📋 Task & Sub-task Management
- **Sub-tasks Checklist**: Break down complex tasks into smaller actionable steps.
- **Bidirectional Sync**: Completing all sub-tasks marks the main task complete, and unchecking any sub-task resets it to pending.
- **Priority Visuals**: Automatic color coding by priority — **High 🔴**, **Medium 🟡**, and **Low 🟢**.
- **Category Filtering**: Organize tasks into Work, Personal, Study, Health, Shopping, and General.
- **Undo Task Deletion**: 4-second instant `UNDO` action when deleting any task.

### ⏱️ Focus Mode (Pomodoro Timer)
- **Pomodoro Timer**: Integrated focus timer with customizable minute presets (15, 25, 45, 60 mins).
- **Task Selector**: Pick any pending task to focus on via a smooth bottom sheet picker.

### 📅 Calendar & Timeline Schedule
- **Date Timeline Picker**: Horizontal date timeline for quick day switching.
- **Collapsible Calendar**: Full month interactive calendar view with smooth collapse/expand toggling.

### 🔔 Smart Reminders & Notifications
- **Scheduled Alarms**: Local push notifications delivered automatically before task start times.
- **Notification Control**: Automatic cancellation upon task completion or deletion.

### 📊 Productivity Stats & UX
- **Interactive Streak Badge**: Live daily progress tracker (`X/Y Tasks Done`) with a stats bottom sheet.
- **Instant Light & Dark Mode**: Instant theme switching with zero animation lag.
- **Avatar Preview**: Long-press on user avatar to view a high-res full-screen image preview.
- **Smart Real-time Search**: Search across task titles, notes, and sub-task steps simultaneously.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter SDK](https://flutter.dev/) (Dart 3.x)
- **Local Database**: [Hive](https://pub.dev/packages/hive) & [Hive Flutter](https://pub.dev/packages/hive_flutter)
- **Backend / Auth**: [Supabase Flutter](https://pub.dev/packages/supabase_flutter)
- **Local Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **State & UI Tools**: `ValueListenableBuilder`, `date_picker_timeline`, `lottie`, `google_fonts`, `gap`
- **Architecture**: Feature-First Clean Architecture

---

## 📁 Project Structure

```text
lib/
├── core/
│   ├── functions/         # Navigation helpers
│   ├── models/            # TaskModel & Hive Adapters
│   ├── services/          # LocalStorage (Hive), Supabase, NotificationService
│   ├── utils/             # Colors, TextStyles, App Themes
│   └── widgets/           # Reusable widgets (UserAvatar, TaskItem)
└── features/
    ├── add_task/          # Add & Edit Task view
    ├── auth/              # Login, Sign Up, Remember Me
    ├── calendar/          # Calendar & Schedule view
    ├── focus/             # Focus / Pomodoro view
    ├── home/              # Main dashboard, Search, Progress stats
    ├── intro/             # Splash & Onboarding views
    ├── main_layout/       # Bottom Navigation Bar Container
    └── profile/           # User Profile & App Settings
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (`>= 3.4.4`)
- Android Studio / VS Code
- A physical Android/iOS device or Emulator

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/YourUsername/taskatii.git
   cd taskatii
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Generate Hive Adapters** (if modifying models):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**:
   ```bash
   flutter run
   ```

5. **Build Release APK**:
   ```bash
   flutter build apk --split-per-abi
   ```

---

## 🤝 Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git file -u origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📜 License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  Crafted with ❤️ using <b>Flutter</b>
</div>
