import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/models/user_models/task_model.dart';
import 'package:flutter_app/models/user_models/app_user.dart';

class TaskDashboardWidget extends StatefulWidget {
  final Map<AppUser, List<TaskModel>> tasksByUser;
  final AppUser currentUser;
  final VoidCallback? onTradeTask;
  final VoidCallback? onDeleteTask;
  final VoidCallback? onAddTask;
  final VoidCallback? onMarkHelpNeeded;
  final Function(TaskModel)? onTaskSelected;

  const TaskDashboardWidget({
    required this.tasksByUser,
    required this.currentUser,
    this.onTradeTask,
    this.onDeleteTask,
    this.onAddTask,
    this.onMarkHelpNeeded,
    this.onTaskSelected,
    super.key,
  });

  @override
  State<TaskDashboardWidget> createState() => _TaskDashboardWidgetState();
}

class _TaskDashboardWidgetState extends State<TaskDashboardWidget> {
  TaskModel? selectedTask;
  AppUser? selectedTaskUser;

  List<AppUser> getSortedUsers() {
    List<AppUser> users = widget.tasksByUser.keys.toList();
    users.sort((a, b) {
      String nameA =
          '${a.displayFirstName ?? ''} ${a.displayLastName ?? ''}'.trim();
      String nameB =
          '${b.displayFirstName ?? ''} ${b.displayLastName ?? ''}'.trim();
      return nameA.compareTo(nameB);
    });
    return users;
  }

  bool canDeleteTask(TaskModel task) {
    return selectedTaskUser?.uid == widget.currentUser.uid;
  }

  bool canMarkHelpNeeded(TaskModel task) {
    return selectedTaskUser?.uid == widget.currentUser.uid;
  }

  void handleTradeTask() {
    if (selectedTask != null && widget.onTradeTask != null) {
      widget.onTradeTask!();
    } else {
      Get.snackbar('Trade Task', 'Please select a task first');
    }
  }

  void handleDeleteTask() {
    if (selectedTask == null) {
      Get.snackbar('Delete Task', 'Please select a task first');
      return;
    }

    if (!canDeleteTask(selectedTask!)) {
      Get.snackbar(
        'Permission Denied',
        'You can only delete your own tasks',
      );
      return;
    }

    if (widget.onDeleteTask != null) {
      widget.onDeleteTask!();
    }
  }

  void handleAddTask() {
    if (widget.onAddTask != null) {
      widget.onAddTask!();
    }
  }

  void handleMarkHelpNeeded() {
    if (selectedTask == null) {
      Get.snackbar('Mark as Help Needed', 'Please select a task first');
      return;
    }

    if (!canMarkHelpNeeded(selectedTask!)) {
      Get.snackbar(
        'Permission Denied',
        'You can only mark your own tasks as help needed',
      );
      return;
    }

    if (widget.onMarkHelpNeeded != null) {
      widget.onMarkHelpNeeded!();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<AppUser> sortedUsers = getSortedUsers();

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: const Color(0xFFFFB743),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Task Dashboard',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 62, 62),
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: sortedUsers.isEmpty
                ? const Center(
                    child: Text('No tasks available'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: sortedUsers.length,
                    itemBuilder: (context, index) {
                      AppUser user = sortedUsers[index];
                      List<TaskModel> userTasks = widget.tasksByUser[user] ?? [];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildUserTasksSection(user, userTasks),
                      );
                    },
                  ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFB743),
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.swap_horiz,
                  tooltip: 'Trade Task',
                  onPressed: handleTradeTask,
                  enabled: selectedTask != null,
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  tooltip: 'Delete / Mark Completed',
                  onPressed: handleDeleteTask,
                  enabled: selectedTask != null && canDeleteTask(selectedTask!),
                ),
                _buildActionButton(
                  icon: Icons.add,
                  tooltip: 'Add Task',
                  onPressed: handleAddTask,
                ),
                _buildActionButton(
                  icon: Icons.flag,
                  tooltip: 'Mark as Help Needed',
                  onPressed: handleMarkHelpNeeded,
                  enabled: selectedTask != null && canMarkHelpNeeded(selectedTask!),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTasksSection(AppUser user, List<TaskModel> userTasks) {
    String userName =
        '${user.displayFirstName ?? 'Unknown'} ${user.displayLastName ?? ''}'
            .trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          userName,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8.0),
        ...userTasks.map((task) => _buildTaskItem(task, user)).toList(),
      ],
    );
  }

  Widget _buildTaskItem(TaskModel task, AppUser assignedUser) {
    bool isSelected =
        selectedTask == task && selectedTaskUser == assignedUser;
    bool isCurrentUserTask = assignedUser.uid == widget.currentUser.uid;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTask = task;
          selectedTaskUser = assignedUser;
        });
        if (widget.onTaskSelected != null) {
          widget.onTaskSelected!(task);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
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
                    task.taskName,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (task.helpFlagged)
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Due Date
                Text(
                  'Due: ${_formatDate(task.dateDue)}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: isSelected ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ],
            ),
            if (task.gcTask) ...[
              const SizedBox(height: 8.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progress: ${task.taskProgress}',
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
                      value: _parseProgress(task.taskProgress),
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
            if (task.dateCompleted != null) ...[
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

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool enabled = true,
  }) {
    return Tooltip(
      message: tooltip,
      child: FloatingActionButton(
        mini: true,
        onPressed: enabled ? onPressed : null,
        backgroundColor: enabled
            ? const Color(0xFFFFB743)
            : Colors.grey[400],
        foregroundColor: Colors.black,
        elevation: enabled ? 6.0 : 0,
        shape: const CircleBorder(),
        child: Icon(icon),
      ),
    );
  }

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
}
