import 'package:flutter/material.dart';
import 'package:flutter_app/enums/navigation_enum.dart';
import 'package:flutter_app/models/user_models/task_model.dart';
import 'package:flutter_app/models/user_models/app_user.dart';

class Trade extends StatefulWidget {
  final Function(NavigationPage)? onNavigate;
  const Trade({super.key, this.onNavigate});

  @override
  State<Trade> createState() => _TradeState();
}

class _TradeState extends State<Trade> {
  String? selectedHiveId;
  TaskModel? selectedTask;
  AppUser? selectedTaskUser;
  int currentStep = 0;
  String? targetHiveId;
  TaskModel? targetTask;
  AppUser? targetTaskUser;
  final String currentUserUid = 'user1';

  final List<HiveData> mockHives = [
    HiveData(
      id: 'hive1',
      name: 'Math Class',
      tasks: [
        TaskModel(
          task_name: 'Complete Math Homework',
          tradeable: true,
          date_assigned: DateTime.now(),
          date_due: DateTime.now().add(const Duration(days: 3)),
          taskType: 'homework',
          task_description: 'Finish chapter 5 exercises',
          users_tasked: [
            AppUser(
              uid: 'user1',
              displayFirstName: 'Alice',
              displayLastName: 'Johnson',
              hasCompletedSetup: true,
            )
          ],
          hive_ID: 'hive1',
          hive_name: 'Math Class',
          difficulty: 'medium',
          gc_task: false,
        ),
        TaskModel(
          task_name: 'Read Science Chapter',
          tradeable: true,
          date_assigned: DateTime.now(),
          date_due: DateTime.now().add(const Duration(days: 2)),
          taskType: 'reading',
          task_description: 'Read pages 45-67',
          users_tasked: [
            AppUser(
              uid: 'user2',
              displayFirstName: 'Bob',
              displayLastName: 'Smith',
              hasCompletedSetup: true,
            )
          ],
          hive_ID: 'hive1',
          hive_name: 'Math Class',
          difficulty: 'easy',
          gc_task: false,
        ),
      ],
    ),
    HiveData(
      id: 'hive2',
      name: 'Science Lab',
      tasks: [
        TaskModel(
          task_name: 'Lab Report',
          tradeable: true,
          date_assigned: DateTime.now(),
          date_due: DateTime.now().add(const Duration(days: 4)),
          taskType: 'lab',
          task_description: 'Complete experiment analysis',
          users_tasked: [
            AppUser(
              uid: 'user3',
              displayFirstName: 'Charlie',
              displayLastName: 'Brown',
              hasCompletedSetup: true,
            )
          ],
          hive_ID: 'hive2',
          hive_name: 'Science Lab',
          difficulty: 'hard',
          gc_task: false,
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    if (mockHives.isNotEmpty) {
      selectedHiveId = mockHives.first.id;
    }
  }

  HiveData? get selectedHive =>
      mockHives.firstWhere((h) => h.id == selectedHiveId,
          orElse: () => HiveData(id: '', name: '', tasks: []));

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  double _parseProgress(String progress) {
    final Map<String, double> progressMap = {
      'unstarted': 0.0,
      'in progress': 0.5,
      'completed': 1.0,
    };
    return progressMap[progress.toLowerCase()] ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final List<TaskModel> sourceTasks = selectedHive?.tasks
            .where((t) => t.users_tasked.isNotEmpty && t.users_tasked[0].uid == currentUserUid)
            .toList() ??
        [];
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentStep == 0 ? '1. Select a task to give' : '2. Select a task to receive',
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                if (currentStep == 1)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentStep = 0;
                        targetHiveId = null;
                        targetTask = null;
                        targetTaskUser = null;
                      });
                    },
                    child: const Text('Back'),
                  ),
              ],
            ),
          ),
          if (currentStep == 0)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black12,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButton<String>(
                    value: selectedHiveId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Select a Hive to Trade From'),
                    items: mockHives
                        .map((hive) => DropdownMenuItem<String>(
                              value: hive.id,
                              child: Text(
                                hive.name,
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedHiveId = newValue;
                        selectedTask = null;
                        selectedTaskUser = null;
                      });
                    },
                  ),
                ),
              ),
            ),
          Expanded(
            child: currentStep == 0
                ? (sourceTasks.isEmpty
                    ? const Center(
                        child: Text(
                          'No own tasks available in this hive',
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB743),
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 10,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ListView.builder(
                              itemCount: sourceTasks.length,
                              itemBuilder: (context, index) {
                                TaskModel task = sourceTasks[index];
                                AppUser taskUser = task.users_tasked.isNotEmpty
                                    ? task.users_tasked[0]
                                    : AppUser(
                                        uid: 'unknown',
                                        displayFirstName: 'Unknown',
                                        displayLastName: 'User',
                                        hasCompletedSetup: true,
                                      );

                                return _buildTaskItem(task, taskUser);
                              },
                            ),
                          ),
                        ),
                      ))
                :
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Column(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(color: Colors.black, width: 1.5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButton<String>(
                              value: targetHiveId,
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: const Text('Select a Hive to Trade To'),
                              items: mockHives
                                  .where((h) => h.id != selectedHiveId)
                                  .map((hive) => DropdownMenuItem<String>(
                                        value: hive.id,
                                        child: Text(hive.name),
                                      ))
                                  .toList(),
                              onChanged: (String? v) {
                                setState(() {
                                  targetHiveId = v;
                                  targetTask = null;
                                  targetTaskUser = null;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12.0),
                        Expanded(
                          child: targetHiveId == null
                              ? const Center(
                                  child: Text('Select a target hive to see tasks'),
                                )
                              : Builder(builder: (context) {
                                  final hive = mockHives.firstWhere((h) => h.id == targetHiveId);
                                  final List<TaskModel> targetTasks = hive.tasks
                                      .where((t) => t.users_tasked.isNotEmpty && t.users_tasked[0].uid != currentUserUid)
                                      .toList();

                                  if (targetTasks.isEmpty) {
                                    return const Center(child: Text('No other users\' tasks in this hive'));
                                  }

                                  return ListView.builder(
                                    itemCount: targetTasks.length,
                                    itemBuilder: (context, index) {
                                      final task = targetTasks[index];
                                      final user = task.users_tasked.isNotEmpty
                                          ? task.users_tasked[0]
                                          : AppUser(
                                              uid: 'unknown',
                                              displayFirstName: 'Unknown',
                                              displayLastName: 'User',
                                              hasCompletedSetup: true,
                                            );

                                      final bool isSelected = targetTask == task && targetTaskUser == user;

                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            targetTask = task;
                                            targetTaskUser = user;
                                          });
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.only(bottom: 10.0),
                                          padding: const EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: isSelected ? Colors.orange[800] : Colors.white,
                                            borderRadius: BorderRadius.circular(10.0),
                                            border: Border.all(
                                              color: isSelected ? Colors.red : Colors.grey[300]!,
                                              width: isSelected ? 2.0 : 1.0,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(child: Text(task.task_name)),
                                              Text('By: ${user.displayFirstName ?? 'Unknown'}'),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }),
                        ),
                      ],
                    ),
                  ),
          ),
          // Sending the actual request down here
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: currentStep == 0
                        ? (selectedTask != null
                            ? () {
                                setState(() {
                                  currentStep = 1;
                                  targetHiveId = null;
                                  targetTask = null;
                                  targetTaskUser = null;
                                });
                              }
                            : null)
                        : (targetTask != null ? _sendTradeRequest : null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (currentStep == 0 ? (selectedTask != null) : (targetTask != null))
                          ? const Color(0xFFFFB743)
                          : Colors.grey[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 16.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        side: const BorderSide(
                          color: Colors.black,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: Text(
                      currentStep == 0 ? 'Choose Target Task' : 'Send Trade Request',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: (currentStep == 0 ? (selectedTask != null) : (targetTask != null)) ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                if (currentStep == 1) const SizedBox(width: 12.0),
                if (currentStep == 1)
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        currentStep = 0;
                        targetHiveId = null;
                        targetTask = null;
                        targetTaskUser = null;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendTradeRequest() {
    // Show confirmation dialog and reset to first step.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trade Request Sent'),
        content: const Text('Your trade request has been sent.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                // Reset flow back to first page
                currentStep = 0;
                selectedTask = null;
                selectedTaskUser = null;
                targetHiveId = null;
                targetTask = null;
                targetTaskUser = null;
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task, AppUser assignedUser) {
    bool isSelected =
        selectedTask == task && selectedTaskUser == assignedUser;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTask = task;
          selectedTaskUser = assignedUser;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[800] : Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[400]!,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.red.withAlpha(120),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.task_name,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.help_flagged)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: const Text(
                      'Help Needed',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8.0),
            // Assigned User and Due Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'By: ${assignedUser.displayFirstName ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: isSelected ? Colors.white70 : Colors.grey[700],
                  ),
                ),
                Text(
                  'Due: ${_formatDate(task.date_due)}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: isSelected ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Chip(
              label: Text(
                task.difficulty.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: _getDifficultyColor(task.difficulty),
            ),
            if (task.gc_task) ...[
              const SizedBox(height: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress: ${task.task_progress}',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isSelected ? Colors.white70 : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: LinearProgressIndicator(
                      value: _parseProgress(task.task_progress),
                      minHeight: 6.0,
                      backgroundColor:
                          isSelected ? Colors.grey[600] : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSelected ? Colors.white : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (task.date_completed != null) ...[
              const SizedBox(height: 8.0),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: const Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class HiveData {
  final String id;
  final String name;
  final List<TaskModel> tasks;

  HiveData({
    required this.id,
    required this.name,
    required this.tasks,
  });
}