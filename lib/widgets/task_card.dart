import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/day_planner_provider.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import 'task_completion_logger.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatus.completed;
    final isOverrun = task.status == TaskStatus.overrun;

    return GestureDetector(
      onTap: () => _showCompletionLogger(context),
      onLongPress: () => _showCompletionLogger(context),
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: TaskTypeUtils.getColor(task.type),
              width: 4,
            ),
            top: isOverrun
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
            bottom: isOverrun
                ? const BorderSide(color: Colors.red, width: 2)
                : BorderSide.none,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and status
            Row(
              children: [
                Icon(
                  TaskTypeUtils.getIcon(task.type),
                  color: TaskTypeUtils.getColor(task.type),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? Colors.grey
                          : const Color(0xFF1F1B16),
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 16,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Time and duration
            Text(
              '${TimeUtils.formatTime(task.startTime)} → ${TimeUtils.formatTime(task.endTime)}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  TimeUtils.formatDuration(task.durationMinutes),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                if (task.alarmSet)
                  const Icon(
                    Icons.alarm,
                    size: 14,
                    color: Colors.orange,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionLogger(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => TaskCompletionLogger(
        task: task,
        onComplete: (log) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Task logged successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
