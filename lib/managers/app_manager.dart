import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_reminder_app/core/constants/color_constants.dart';
import 'package:timezone/data/latest.dart' as tz;

class AppManager {
  static Future<void> initialize() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primaryColor,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.primaryColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    tz.initializeTimeZones();
  }

  static Future<Database> initializeDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'tasks.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE tasks(id INTEGER PRIMARY KEY, title TEXT, description TEXT, reminderTime TEXT, recurrence TEXT)",
        );
      },

      version: 1, // Increment the version number to trigger onUpgrade
    );
  }
}
