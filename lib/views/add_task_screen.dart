// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
// import '../core/blocs/task/task_bloc.dart';
// import '../core/blocs/task/task_event.dart';
// import '../core/models/task.dart';

// class AddTaskScreen extends StatefulWidget {
//   const AddTaskScreen({super.key});

//   @override
//   AddTaskScreenState createState() => AddTaskScreenState();
// }

// class AddTaskScreenState extends State<AddTaskScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String _title = '';
//   String _description = '';
//   DateTime _reminderTime = DateTime.now();
//   RecurrenceType _recurrenceType = RecurrenceType.daily;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Add New Task'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Task Title'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a task title';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _title = value!;
//                 },
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: 'Description'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) {
//                   _description = value!;
//                 },
//               ),
//               ListTile(
//                 title: Text(
//                   'Reminder Time: ${_reminderTime.toLocal().toString()}',
//                   style: TextStyle(fontSize: 16),
//                 ),
//                 trailing: Icon(Icons.date_range),
//                 onTap: () {
//                   DatePicker.showDateTimePicker(
//                     context,
//                     showTitleActions: true,
//                     minTime: DateTime.now(),
//                     onConfirm: (date) {
//                       setState(() {
//                         _reminderTime = date;
//                       });
//                     },
//                     currentTime: _reminderTime,
//                     locale: LocaleType.en,
//                   );
//                 },
//               ),
//               DropdownButtonFormField<RecurrenceType>(
//                 value: _recurrenceType,
//                 decoration: InputDecoration(labelText: 'Recurrence'),
//                 onChanged: (value) {
//                   setState(() {
//                     _recurrenceType = value!;
//                   });
//                 },
//                 items: RecurrenceType.values
//                     .map((e) => DropdownMenuItem(
//                           value: e,
//                           child: Text(e.toString().split('.').last),
//                         ))
//                     .toList(),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: ElevatedButton(
//                   onPressed: _saveTask,
//                   child: Text('Save Task'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// ignore_for_file: use_build_context_synchronously

//   void _saveTask() {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState?.save();
//       final newTask = Task(
//         title: _title,
//         description: _description,
//         reminderTime: _reminderTime,
//         isRecurring: true,
//         recurrenceType: _recurrenceType,
//       );
//       BlocProvider.of<TaskBloc>(context).add(AddTaskEvent(newTask));
//       Navigator.pop(context); // Close the screen after adding the task
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_reminder_app/extensions/app_extensions.dart';
import 'package:task_reminder_app/services/notification_helper.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({
    super.key,
    required this.database,
    required this.fetchTasks,
  });
  final Database database;
  final Function fetchTasks;

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  String _selectedRecurrence = 'daily';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          'Add Task',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0.sp),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () async {
                final now = DateTime.now();
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: now,
                  firstDate: now,
                  lastDate: now.add(Duration(days: 365)),
                );
                if (pickedDate != null) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      _selectedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                }
              },
              child: Text(_selectedDateTime == null
                  ? 'Pick Date and Time'
                  : _selectedDateTime.toString()),
            ),
            SizedBox(height: 20.h),
            DropdownButton<String>(
              value: _selectedRecurrence,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRecurrence = newValue!;
                });
              },
              items: <String>['daily', 'weekly', 'monthly']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.capitalize()),
                );
              }).toList(),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _selectedDateTime != null) {
                  NotificationHelper.addTask(
                    _titleController.text,
                    _descriptionController.text,
                    _selectedDateTime!,
                    _selectedRecurrence,
                    widget.database,
                    widget.fetchTasks,
                  );
                  Navigator.pop(context, true);
                }
              },
              child: Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }
}
