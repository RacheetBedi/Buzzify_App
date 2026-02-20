import 'package:flutter/material.dart';
import 'package:flutter_app/enums/navigation_enum.dart';
import 'package:flutter_app/models/user_models/task_model.dart';
import 'package:flutter_app/widgets/tasks_deadline_widget.dart';

class TrackingBody extends StatelessWidget {
  const TrackingBody({super.key, required void Function(NavigationPage page) onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        padding: const EdgeInsets.only(top: 10.0),
        shrinkWrap: true,
        children: [
          //Need to get the list of tasks from the database and pass it to the TasksDeadlineWidget. For now, I'm just passing fake tasks for testing..
          TasksDeadlineWidget(tasks: [
            TaskModel(
              taskName: 'Task 1',
              dateDue: DateTime.now().add(const Duration(days: 2)),
              dateAssigned: DateTime.now(),
              taskDescription: 'Description 1',
              usersTasked: [],
              hiveUiD: '1',
              hiveName: 'Hive 1',
              difficulty: 'Medium',
              taskType: 'Work',
              gcTask: false,
              tradeable: false,
            ),
            TaskModel(
              taskName: 'Task 2',
              dateDue: DateTime.now().add(const Duration(days: 5)),
              dateAssigned: DateTime.now(),
              taskDescription: 'Description 2',
              usersTasked: [],
              hiveUiD: '2',
              hiveName: 'Hive 2',
              difficulty: 'Hard',
              taskType: 'Personal',
              gcTask: false,
              tradeable: false,
            ),
          ]),
        ],
      ),
    );
  }
}