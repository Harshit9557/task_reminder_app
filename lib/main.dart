// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:task_reminder_app/core/constants/figma_constraints.dart';
// import 'package:task_reminder_app/managers/app_manager.dart';
// import 'core/blocs/task/task_bloc.dart';
// import 'data/repositories/task_repository.dart';
// import 'views/task_list_screen.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await AppManager.initialize();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => TaskBloc(taskRepository: TaskRepository()),
//       child: ScreenUtilInit(
//           designSize: const Size(
//             FigmaValueConstants.screenWidth,
//             FigmaValueConstants.screenHeight,
//           ),
//           builder: (context, child) {
//             return MaterialApp(
//               theme: ThemeData.light(),
//               darkTheme: ThemeData.dark(),
//               debugShowCheckedModeBanner: false,
//               title: 'Task Reminder',
//               themeMode: ThemeMode.system,
//               scrollBehavior: ScrollConfiguration.of(context).copyWith(
//                 physics: const BouncingScrollPhysics(),
//               ),
//               home: TaskListScreen(),
//             );
//           }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:sqflite/sqflite.dart';
import 'package:task_reminder_app/core/constants/figma_constraints.dart';

import 'package:task_reminder_app/managers/app_manager.dart';
import 'package:task_reminder_app/views/task_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppManager.initialize();
  final database = await AppManager.initializeDatabase();

  runApp(TaskReminderApp(database: database));
}

class TaskReminderApp extends StatelessWidget {
  final Database database;

  const TaskReminderApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(
        FigmaValueConstants.screenWidth,
        FigmaValueConstants.screenHeight,
      ),
      child: MaterialApp(
        title: 'Task Reminder',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.teal[800],
          ),
        ),
        darkTheme: ThemeData.dark(),
        themeMode: ThemeMode.system,
        home: TaskListScreen(database: database),
      ),
    );
  }
}
