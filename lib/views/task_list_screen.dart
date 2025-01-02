// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../core/blocs/task/task_bloc.dart';
// import '../core/blocs/task/task_state.dart';
// import 'add_task_screen.dart'; // Import the AddTaskScreen

// class TaskListScreen extends StatelessWidget {
//   const TaskListScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Task Reminder'),
//       ),
//       body: BlocBuilder<TaskBloc, TaskState>(
//         builder: (context, state) {
//           print(state);
//           if (state is TaskLoadingState) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is TaskLoadedState) {
//             final tasks = state.tasks;
//             return ListView.builder(
//               itemCount: tasks.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(tasks[index].title),
//                   subtitle: Text('Reminder at: ${tasks[index].reminderTime}'),
//                 );
//               },
//             );
//           }
//           return Center(child: Text('No tasks available.'));
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Navigate to AddTaskScreen
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => AddTaskScreen()),
//           );
//         },
//         child: Icon(Icons.add),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_reminder_app/services/notification_helper.dart';
import 'package:task_reminder_app/views/add_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  final Database database;

  const TaskListScreen({super.key, required this.database});

  @override
  TaskListScreenState createState() => TaskListScreenState();
}

class TaskListScreenState extends State<TaskListScreen> {
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    NotificationHelper.initializeNotifications();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    final List<Map<String, dynamic>> fetchedTasks =
        await widget.database.query('tasks');
    setState(() {
      tasks = fetchedTasks;
    });
    NotificationHelper.rescheduleNotifications(tasks);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tasks',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      body: tasks.isEmpty
          ? Center(child: Text('No tasks scheduled yet!'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                final reminderTime =
                    DateTime.parse(task['reminderTime']).toLocal();
                return Card(
                  margin:
                      EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                  elevation: 5.sp,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.sp),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16.sp),
                    title: Text(
                      task['title'],
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[800],
                      ),
                    ),
                    subtitle: Text(
                      task['description'] ?? '',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    trailing: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${reminderTime.hour}:${reminderTime.minute}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.teal,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () => NotificationHelper.deleteTask(
                              task['id'],
                              widget.database,
                              fetchTasks,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTaskScreen(
                database: widget.database,
                fetchTasks: fetchTasks,
              ),
            ),
          );
          if (result == true) fetchTasks();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
