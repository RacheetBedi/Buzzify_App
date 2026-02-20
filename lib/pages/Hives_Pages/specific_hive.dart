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
        taskName: 'Complete Math Homework',
        tradeable: true,
        dateAssigned: DateTime.now(),
        dateDue: DateTime.now().add(const Duration(days: 3)),
        taskType: 'homework',
        taskDescription: 'Finish chapter 5 exercises',
        usersTasked: [fakeUser1],
        hiveUiD: 'hive1',
        hiveName: widget.hiveName,
        difficulty: 'medium',
        gcTask: false,
      ),
      TaskModel(
        taskName: 'Read Science Chapter',
        tradeable: false,
        dateAssigned: DateTime.now(),
        dateDue: DateTime.now().add(const Duration(days: 2)),
        taskType: 'reading',
        taskDescription: 'Read pages 45-67',
        usersTasked: [fakeUser1],
        hiveUiD: 'hive1',
        hiveName: widget.hiveName,
        difficulty: 'easy',
        gcTask: false,
      ),
    ];

    final fakeTasks2 = [
      TaskModel(
        taskName: 'Google Classroom Assignment',
        tradeable: true,
        dateAssigned: DateTime.now(),
        dateDue: DateTime.now().add(const Duration(days: 5)),
        taskType: 'assignment',
        taskDescription: 'Submit essay on literature',
        usersTasked: [fakeUser2],
        hiveUiD: 'hive1',
        hiveName: widget.hiveName,
        difficulty: 'hard',
        gcTask: true,
        taskProgress: 'in progress',
      ),
    ];

    final fakeTasks3 = [
      TaskModel(
        taskName: 'Write Essay',
        tradeable: true,
        dateAssigned: DateTime.now(),
        dateDue: DateTime.now().add(const Duration(days: 1)),
        taskType: 'essay',
        taskDescription: '500-word essay on climate change',
        usersTasked: [fakeUser3],
        hiveUiD: 'hive1',
        hiveName: widget.hiveName,
        difficulty: 'hard',
        gcTask: false,
      ),
      TaskModel(
        taskName: 'Study for Test',
        tradeable: false,
        dateAssigned: DateTime.now(),
        dateDue: DateTime.now().add(const Duration(days: 7)),
        taskType: 'study',
        taskDescription: 'Review biology notes',
        usersTasked: [fakeUser3],
        hiveUiD: 'hive1',
        hiveName: widget.hiveName,
        difficulty: 'medium',
        helpFlagged: true,
        gcTask: false,
      ),
      TaskModel(
        taskName: 'Completed Project',
        tradeable: true,
        dateAssigned: DateTime.now().subtract(const Duration(days: 14)),
        dateDue: DateTime.now().subtract(const Duration(days: 7)),
        taskType: 'project',
        taskDescription: 'Science fair project',
        dateCompleted: DateTime.now().subtract(const Duration(days: 3)),
        usersTasked: [fakeUser3],
        hiveUiD: 'hive1',
        hiveName: widget.hiveName,
        difficulty: 'hard',
        gcTask: false,
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