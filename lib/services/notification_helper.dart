import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationHelper {
  static FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotifications() async {
    localNotifications = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await localNotifications.initialize(settings,
        onDidReceiveNotificationResponse: selectNotification);
  }

  static Future<void> rescheduleNotifications(List tasks) async {
    // Reschedule notifications for tasks that have a reminder time in the future
    final now = tz.TZDateTime.now(tz.local);
    for (var task in tasks) {
      final reminderTime = DateTime.parse(task['reminderTime']);
      final tzReminderTime = tz.TZDateTime.from(reminderTime, tz.local);
      if (tzReminderTime.isAfter(now)) {
        await scheduleNotification(
          task['id'],
          task['title'],
          reminderTime,
          task['recurrence'],
        );
      }
    }
  }

  static Future<void> scheduleNotification(
    int id,
    String title,
    DateTime reminderTime,
    String recurrence,
  ) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    final tz.TZDateTime tzReminderTime =
        tz.TZDateTime.from(reminderTime, tz.local);
    log('Scheduled time: $tzReminderTime');
    if (tzReminderTime.isBefore(now)) {
      final tzReminderTime = now.add(Duration(seconds: 5));
      log('Adjusted time to: $tzReminderTime');
      return;
    }
    final androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      importance: Importance.max,
      priority: Priority.high,
      color: Colors.teal,
      playSound: true,
      styleInformation: BigTextStyleInformation(title),
      enableVibration: true,
      additionalFlags: Int32List.fromList(<int>[4]),
      actions: [
        AndroidNotificationAction(
          'mark_done', // Action ID
          'Mark as Done',
          // Action button text
          //icon: 'drawable/ic_done', // Optionally add an icon
        ),
      ],
    );
    const iosDetails = DarwinNotificationDetails(
      categoryIdentifier: 'task_category',
      presentAlert: true,
      presentSound: true,
      presentBadge: true,
    );
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await localNotifications.zonedSchedule(
      id,
      'Task Reminder: $title',
      'It’s time for your task!',
      tzReminderTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    if (recurrence == 'daily') {
      await _scheduleNextNotification(
          id, title, tzReminderTime.add(Duration(days: 1)), recurrence);
    } else if (recurrence == 'weekly') {
      await _scheduleNextNotification(
          id, title, tzReminderTime.add(Duration(days: 7)), recurrence);
    } else if (recurrence == 'monthly') {
      await _scheduleNextNotification(
          id, title, tzReminderTime.add(Duration(days: 30)), recurrence);
    }
  }

  static Future<void> _scheduleNextNotification(
    int id,
    String title,
    tz.TZDateTime reminderTime,
    String recurrence,
  ) async {
    var notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel',
        'Task Reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      ),
      iOS: DarwinNotificationDetails(
        categoryIdentifier: 'task_category',
        presentSound: true,
        presentAlert: true,
        presentBadge: true,
      ),
    );

    await localNotifications.zonedSchedule(
      id,
      'Task Reminder: $title',
      'It’s time for your task!',
      reminderTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static Future<void> addTask(
    String title,
    String description,
    DateTime reminderTime,
    String recurrence,
    Database database,
    fetchTasks,
  ) async {
    final id = await database.insert(
      'tasks',
      {
        'title': title,
        'description': description,
        'reminderTime': reminderTime.toIso8601String(),
        'recurrence': recurrence,
      },
    );
    await scheduleNotification(id, title, reminderTime, recurrence);
    fetchTasks();
    // Trigger haptic feedback when a task is added
    HapticFeedback.lightImpact();
  }

  static Future<void> deleteTask(
    int id,
    Database database,
    Function fetchTasks,
  ) async {
    await database.delete('tasks', where: 'id = ?', whereArgs: [id]);
    localNotifications.cancel(id);
    fetchTasks();
    // Trigger haptic feedback when a task is deleted
    HapticFeedback.mediumImpact();
  }

  // This method handles when a notification action (e.g., "Mark as Done") is selected
  static Future<void> selectNotification(
      NotificationResponse notificationResponse) async {
    if (notificationResponse.actionId == 'mark_done') {
      // Handle the action when the "Mark as Done" button is pressed
      // You can mark the task as completed, update the database, etc.
      log('Task marked as done!');
    }
  }
}
