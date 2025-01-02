# Task Reminder App

This Flutter application allows users to set, view, and manage tasks with reminders. Users can also set tasks to repeat daily, weekly, or monthly. The app uses local notifications to alert users about their tasks, even when the app is closed or the device is restarted.

## Features

- Add, update, and delete tasks.
- Set reminders for tasks with local notifications.
- Tasks can repeat daily, weekly, or monthly.
- Persistent notifications even after app restarts or closure.
- Haptic feedback when a task is added or deleted.
- Platform-specific notification handling for Android and iOS.

## Prerequisites

Before you can run this application, ensure you have the following tools installed:

- **Flutter**: Download and install Flutter from [flutter.dev](https://flutter.dev).
- **Android Studio / Xcode**: You need Android Studio (for Android) or Xcode (for iOS) to run and test the application.
- **SQLite**: The app uses SQLite for persistent data storage. The `sqflite` plugin is included in the dependencies.

## Setup Instructions

1. **Clone the repository**:
   
   git clone https://github.com/yourusername/task_reminder_app.git
   
   cd task_reminder_app

3. **Install dependencies**:   

   Make sure you have Flutter set up and the necessary dependencies installed:

   flutter pub get

3. **Run the app**:

   To run the app on an emulator or physical device:

- **For Android**: Ensure you have an Android emulator running or a physical device connected, then:

   flutter run

- **For iOS**: Make sure you have a working iOS simulator or a physical device connected, then:

   flutter run

4. **Building the app**:

- **For Android**: flutter build apk
- **For iOS**: flutter build ios


## Platform-Specific Implementations

1. **Android**:

- **Local Notifications**: We use flutter_local_notifications for setting up local notifications. The notifications on Android are implemented using Android’s native notification system. The notifications are persistent even after the app is closed, and the application makes use of inexact scheduling to allow notifications to be shown even if the app is not actively running in the background.

- **Haptic Feedback**: The app uses HapticFeedback from Flutter's flutter_local_notifications to provide feedback when tasks are added or deleted.

2. **iOS**:

- **Local Notifications**: Notifications are handled through flutter_local_notifications, which relies on the iOS local notification API. We use DarwinNotificationDetails for scheduling notifications.

- **Recurrence**: For recurrence (daily, weekly, monthly), we use the recurrence field stored in the SQLite database, and then the notifications are scheduled based on this. Each platform handles repeated notifications differently, and care must be taken to adjust the scheduling logic for iOS.

## Challenges Faced:

- **Timezone Handling**: Managing timezone differences for notifications was challenging, as timezones need to be properly managed for both local notifications and scheduled tasks. The timezone package was used to handle this complexity.

- **Notification Persistence**: Ensuring that notifications persist after the app is closed or the phone is restarted required using platform-specific APIs to re-schedule notifications after a restart.

- **Database Schema Migration**: When adding new columns (such as the recurrence column), careful attention was required to implement database migrations properly to prevent schema errors, especially when the app is upgraded from an earlier version.
Future Improvements

- **UI Enhancements**: The current UI can be enhanced to provide a more user-friendly experience with animations and better visual feedback.

- **Task Editing**: Currently, tasks can be added and deleted, but editing an existing task can be implemented in a future release.

- **Advanced Recurrence**: The recurrence system can be further improved to support custom intervals, such as every 3 days or every Monday, rather than just daily, weekly, or monthly.

## License

     This project is licensed under the MIT License - see the LICENSE file for details.

### Key sections explained:

1. **Prerequisites**: Describes the tools needed to set up the app, like Flutter and SQLite.
2. **Setup Instructions**: Step-by-step guide to clone the repository, install dependencies, and run the app on Android/iOS.
3. **Platform-Specific Implementations**: Covers platform-specific details for Android and iOS (e.g., how notifications are handled differently).
4. **Challenges Faced**: Describes any specific issues encountered, like time zone handling, notification persistence, and database migration.
5. **Future Improvements**: Suggests potential future enhancements to the app.
