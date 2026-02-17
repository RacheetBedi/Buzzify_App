import 'package:flutter/material.dart';
import 'package:flutter_app/enums/navigation_enum.dart';
import 'package:flutter_app/widgets/normal_task_widget.dart';
import 'package:flutter_app/widgets/task_dashboard_popup.dart';
import 'package:flutter_app/models/user_models/app_user.dart';
import 'package:flutter_app/models/user_models/task_model.dart';
import 'package:flutter_app/providers/current_user_provider.dart';
import 'package:flutter_app/providers/hive_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SpecificHive extends ConsumerStatefulWidget {
  final Color hiveColor;
  final Icon hiveIcon;
  final String hiveName;
  final Function(NavigationPage)? onNavigate;
  const SpecificHive({required this.hiveColor, required this.hiveIcon, required this.hiveName, super.key, this.onNavigate});
  @override
  ConsumerState<SpecificHive> createState() => _SpecificHiveState();
}
class _SpecificHiveState extends ConsumerState<SpecificHive> {

  @override
  void initState() {
    super.initState();
  }

  void _showTaskDashboard(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    final parentContext = context; // Capture parent context before showing dialog

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final fakeUser1 = AppUser(
      uid: 'user1',
      displayFirstName: 'Alice',
      displayLastName: 'Johnson',
      hasCompletedSetup: true,
    );

    final fakeUser2 = AppUser(
      uid: 'user2',
      displayFirstName: 'Bob',
      displayLastName: 'Smith',
      hasCompletedSetup: true,
    );

    final fakeUser3 = AppUser(
      uid: currentUser.uid,
      displayFirstName: currentUser.displayFirstName ?? 'You',
      displayLastName: currentUser.displayLastName ?? '',
      hasCompletedSetup: true,
    );

    final fakeTasks1 = [
      TaskModel(
        task_name: 'Complete Math Homework',
        tradeable: true,
        date_assigned: DateTime.now(),
        date_due: DateTime.now().add(const Duration(days: 3)),
        taskType: 'homework',
        task_description: 'Finish chapter 5 exercises',
        users_tasked: [fakeUser1],
        hive_ID: 'hive1',
        hive_name: widget.hiveName,
        difficulty: 'medium',
        gc_task: false,
      ),
      TaskModel(
        task_name: 'Read Science Chapter',
        tradeable: false,
        date_assigned: DateTime.now(),
        date_due: DateTime.now().add(const Duration(days: 2)),
        taskType: 'reading',
        task_description: 'Read pages 45-67',
        users_tasked: [fakeUser1],
        hive_ID: 'hive1',
        hive_name: widget.hiveName,
        difficulty: 'easy',
        gc_task: false,
      ),
    ];

    final fakeTasks2 = [
      TaskModel(
        task_name: 'Google Classroom Assignment',
        tradeable: true,
        date_assigned: DateTime.now(),
        date_due: DateTime.now().add(const Duration(days: 5)),
        taskType: 'assignment',
        task_description: 'Submit essay on literature',
        users_tasked: [fakeUser2],
        hive_ID: 'hive1',
        hive_name: widget.hiveName,
        difficulty: 'hard',
        gc_task: true,
        task_progress: 'in progress',
      ),
    ];

    final fakeTasks3 = [
      TaskModel(
        task_name: 'Write Essay',
        tradeable: true,
        date_assigned: DateTime.now(),
        date_due: DateTime.now().add(const Duration(days: 1)),
        taskType: 'essay',
        task_description: '500-word essay on climate change',
        users_tasked: [fakeUser3],
        hive_ID: 'hive1',
        hive_name: widget.hiveName,
        difficulty: 'hard',
        gc_task: false,
      ),
      TaskModel(
        task_name: 'Study for Test',
        tradeable: false,
        date_assigned: DateTime.now(),
        date_due: DateTime.now().add(const Duration(days: 7)),
        taskType: 'study',
        task_description: 'Review biology notes',
        users_tasked: [fakeUser3],
        hive_ID: 'hive1',
        hive_name: widget.hiveName,
        difficulty: 'medium',
        help_flagged: true,
        gc_task: false,
      ),
      TaskModel(
        task_name: 'Completed Project',
        tradeable: true,
        date_assigned: DateTime.now().subtract(const Duration(days: 14)),
        date_due: DateTime.now().subtract(const Duration(days: 7)),
        taskType: 'project',
        task_description: 'Science fair project',
        date_completed: DateTime.now().subtract(const Duration(days: 3)),
        users_tasked: [fakeUser3],
        hive_ID: 'hive1',
        hive_name: widget.hiveName,
        difficulty: 'hard',
        gc_task: false,
      ),
    ];

    Map<AppUser, List<TaskModel>> tasksByUser = {
      fakeUser1: fakeTasks1,
      fakeUser2: fakeTasks2,
      fakeUser3: fakeTasks3,
    };

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: TaskDashboardWidget(
            tasksByUser: tasksByUser,
            currentUser: currentUser,
            onTradeTask: () {
              Navigator.pop(dialogContext);
              widget.onNavigate!(NavigationPage.trade);
            },
            onDeleteTask: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text('Delete task functionality')),
              );
            },
            onAddTask: () {
              Navigator.pop(dialogContext);
              widget.onNavigate?.call(NavigationPage.addTasks);
            },
            onMarkHelpNeeded: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text('Mark as help needed functionality')),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        padding: const EdgeInsets.only(top: 10.0),
        shrinkWrap: true,
        children: [
          const NormalTaskWidget(
            title: "My Tasks",
            tasks: [
              {'name': 'Complete Math Homework', 'description': 'Finish chapter 5 exercises'},
              {'name': 'Read Science Chapter', 'description': 'Read pages 45-67'},
              {'name': 'Write Essay', 'description': '500-word essay on climate change'},
              {'name': 'Study for Test', 'description': 'Review biology notes'},
            ],
          ),
          //Add Google Classroom tasks widget here.
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _showTaskDashboard(context, ref),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000000))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.list, size: 30, color: Color(0xFFFF0000)), SizedBox(width: 10), Text("Task Dashboard", style: TextStyle(fontFamily: 'Jomhuria', fontSize: 40, color: Color(0xFFFF0000)))]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => widget.onNavigate!(NavigationPage.addTasks),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000000))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.track_changes, size: 30, color: Color(0xFF00FF73)), SizedBox(width: 10), Text("Add Tasks", style: TextStyle(fontFamily: 'Jomhuria', fontSize: 40, color: Color(0xFF00FF73)))]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => widget.onNavigate!(NavigationPage.trade),
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100000000))),
            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.swap_horiz, size: 30, color: Colors.white), SizedBox(width: 10), Text("Task Trading", style: TextStyle(fontFamily: 'Jomhuria', fontSize: 40, color: Colors.white))]),
          ),
          //Nectar Points Widget with most recent achievement and points earned.
          //AI Summary of the 2 most recent activities for this hive.
        ],
      ),
    );
  }
}