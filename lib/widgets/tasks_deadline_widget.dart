import 'package:flutter/material.dart';
import 'package:flutter_app/models/user_models/task_model.dart';

//Widget that Central Box: Graphs indicating time left for various assignments.
//Lines color-coded by specific groups (dotted lines for unfinished work, full line for finished work) Bee should be standing on the part where the work is going on (I will import the asset later).
//Bee animations at the end of each line. (NOT REQUIRED FOR NOW)
//Only displays three assignments at once. If more are present, click on the box to receive a popup:
//The popup will display similar lines, color-coded by group (with the key button at the top which opens key popup)

class TasksDeadlineWidget extends StatefulWidget {
  final List<TaskModel> tasks;
  final Map<String, Color>? hiveColorMap;

  const TasksDeadlineWidget({
    super.key,
    required this.tasks,
    this.hiveColorMap,
  });

  @override
  State<TasksDeadlineWidget> createState() => _TasksDeadlineWidgetState();
}

class _TasksDeadlineWidgetState extends State<TasksDeadlineWidget> {
  late List<TaskModel> sortedTasks;

  @override
  void initState() {
    super.initState();
    _sortTasksByDeadline();
  }

  @override
  void didUpdateWidget(TasksDeadlineWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sortTasksByDeadline();
  }

  void _sortTasksByDeadline() {
    sortedTasks = List<TaskModel>.from(widget.tasks);
    sortedTasks.sort((a, b) => a.dateDue.compareTo(b.dateDue));
  }

  Color _getHiveColor(String hiveName) {
    if (widget.hiveColorMap != null && widget.hiveColorMap!.containsKey(hiveName)) {
      return widget.hiveColorMap![hiveName]!;
    }
    final colors = [
      const Color.fromARGB(255, 255, 107, 107),
      const Color.fromARGB(255, 255, 193, 7),
      const Color.fromARGB(255, 76, 175, 80),
      const Color.fromARGB(255, 33, 150, 243),
      const Color.fromARGB(255, 156, 39, 176),
      const Color.fromARGB(255, 255, 152, 0),
    ];
    return colors[hiveName.hashCode % colors.length];
  }

  String _getTimeRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);

    if (difference.isNegative) {
      return 'Overdue';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h left';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m left';
    } else {
      return 'Due soon';
    }
  }

  double _getProgressPercentage(TaskModel task) {
    final now = DateTime.now();
    final assigned = task.dateAssigned;
    final due = task.dateDue;

    final totalDuration = due.difference(assigned).inHours;
    final elapsedDuration = now.difference(assigned).inHours;

    if (totalDuration <= 0) return 0;
    final percentage = (elapsedDuration / totalDuration).clamp(0.0, 1.0);
    return percentage;
  }

  Widget _buildDeadlineBar(TaskModel task) {
    final hiveColor = _getHiveColor(task.hiveName);
    final isCompleted = task.dateCompleted != null;
    final progress = _getProgressPercentage(task);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.taskName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getTimeRemaining(task.dateDue),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isCompleted
                      ? const Color.fromARGB(255, 76, 175, 80)
                      : const Color.fromARGB(255, 255, 107, 107),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: CustomPaint(
              painter: _DeadlineBarPainter(
                color: hiveColor,
                progress: progress,
                isCompleted: isCompleted,
              ),
              size: const Size(double.infinity, 12),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.hiveName,
            style: const TextStyle(
              fontSize: 11,
              color: Color.fromARGB(179, 66, 66, 66),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllTasksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFFFB743),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Deadlines',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: sortedTasks.map((task) => _buildDeadlineBar(task)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TaskModel> displayedTasks = sortedTasks.take(3).toList();
    int totalTasks = sortedTasks.length;

    return GestureDetector(
      onTap: totalTasks > 3 ? () => _showAllTasksDialog(context) : null,
      child: Card(
        elevation: 4,
        color: const Color(0xFFFFB743),
        margin: const EdgeInsets.all(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Task Deadlines',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total tasks: $totalTasks',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color.fromARGB(255, 41, 159, 255),
                ),
              ),
              const SizedBox(height: 16),
              if (displayedTasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No tasks assigned yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(179, 66, 66, 66),
                    ),
                  ),
                )
              else
                ...displayedTasks.map((task) => _buildDeadlineBar(task)),
              if (totalTasks > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tap to see all ${totalTasks - 3} more tasks',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 41, 159, 255),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeadlineBarPainter extends CustomPainter {
  final Color color;
  final double progress;
  final bool isCompleted;

  _DeadlineBarPainter({
    required this.color,
    required this.progress,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final filledPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final fillBackgroundPaint = Paint()
      ..color = const Color(0xFFFFB743)
      ..style = PaintingStyle.fill;

    final barHeight = size.height;
    final barWidth = size.width;
    const cornerRadius = 4.0;

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, barWidth, barHeight),
      const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(backgroundRect, fillBackgroundPaint);

    final progressWidth = barWidth * progress;
    final progressRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, progressWidth, barHeight),
      const Radius.circular(cornerRadius),
    );
    canvas.drawRRect(progressRect, filledPaint);

    if (isCompleted) {
      final lineP = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(0, barHeight / 2), Offset(barWidth, barHeight / 2), lineP);
    } else {
      const dashWidth = 4.0;
      const dashSpace = 2.0;
      var startX = 0.0;
      final dashPaint = Paint()
        ..color = color
        ..strokeWidth = 2;

      while (startX < barWidth) {
        final endX = (startX + dashWidth).clamp(0.0, barWidth);
        canvas.drawLine(
          Offset(startX, barHeight / 2),
          Offset(endX as double, barHeight / 2),
          dashPaint,
        );
        startX += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DeadlineBarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.progress != progress ||
        oldDelegate.isCompleted != isCompleted;
  }
}
