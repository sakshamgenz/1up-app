import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/task_log.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import '../providers/day_planner_provider.dart';

class TaskCompletionLogger extends StatefulWidget {
  final Task task;
  final Function(TaskLog) onComplete;

  const TaskCompletionLogger({
    Key? key,
    required this.task,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<TaskCompletionLogger> createState() => _TaskCompletionLoggerState();
}

class _TaskCompletionLoggerState extends State<TaskCompletionLogger> {
  late int _actualHours;
  late int _actualMinutes;
  late int _lecturesCompleted;
  late int _questionsAttempted;
  late Difficulty _difficulty;
  final _notesController = TextEditingController();
  bool _isPartial = false;

  @override
  void initState() {
    super.initState();
    _actualHours = widget.task.durationMinutes ~/ 60;
    _actualMinutes = widget.task.durationMinutes % 60;
    _lecturesCompleted = 0;
    _questionsAttempted = 0;
    _difficulty = Difficulty.medium;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  TaskTypeUtils.getIcon(widget.task.type),
                  color: TaskTypeUtils.getColor(widget.task.type),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Log Completion',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        widget.task.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Task-specific fields
            if (widget.task.type == TaskType.study) ...[_buildStudyFields()],
            if (widget.task.type == TaskType.questions) ...[_buildQuestionsFields()],
            if (widget.task.type == TaskType.break_ ||
                widget.task.type == TaskType.sleep ||
                widget.task.type == TaskType.wasteTime) ...[_buildGeneralFields()],
            const SizedBox(height: 16),
            _buildNotesField(),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _markAsPartial(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accentOrange,
                      side: const BorderSide(color: AppColors.accentOrange),
                    ),
                    child: const Text('Mark as Partial'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _markAsComplete(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark as Complete'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStudyFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lectures/Topics Completed',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (value) {
            setState(() => _lecturesCompleted = int.tryParse(value) ?? 0);
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Planned Duration',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      TimeUtils.formatDuration(widget.task.durationMinutes),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Actual Duration',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'H',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(8),
                          ),
                          onChanged: (value) {
                            setState(
                              () => _actualHours = int.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'M',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(8),
                          ),
                          onChanged: (value) {
                            setState(
                              () => _actualMinutes = int.tryParse(value) ?? 0,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (widget.task.subject != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subject',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(SubjectUtils.getLabel(widget.task.subject!)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        const Text(
          'Difficulty',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: Difficulty.values.map((difficulty) {
            final isSelected = _difficulty == difficulty;
            return GestureDetector(
              onTap: () => setState(() => _difficulty = difficulty),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentOrange.withOpacity(0.2)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: isSelected
                      ? Border.all(color: AppColors.accentOrange, width: 2)
                      : Border.all(color: AppColors.divider),
                ),
                child: Text(
                  difficulty.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.accentOrange : Colors.grey,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuestionsFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Questions Attempted',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter number',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (value) {
            setState(() => _questionsAttempted = int.tryParse(value) ?? 0);
          },
        ),
        const SizedBox(height: 16),
        if (widget.task.subject != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Subject',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Text(SubjectUtils.getLabel(widget.task.subject!)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        const Text(
          'Time Taken',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  setState(() => _actualHours = int.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minutes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  setState(() => _actualMinutes = int.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGeneralFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actual Duration',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  setState(() => _actualHours = int.tryParse(value) ?? 0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Minutes',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  setState(() => _actualMinutes = int.tryParse(value) ?? 0);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes (Optional)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any notes...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Future<void> _markAsComplete() async {
    await _saveCompletion(isPartial: false);
  }

  Future<void> _markAsPartial() async {
    await _saveCompletion(isPartial: true);
  }

  Future<void> _saveCompletion({required bool isPartial}) async {
    final actualDurationMinutes = (_actualHours * 60) + _actualMinutes;

    final taskLog = TaskLog(
      taskId: widget.task.id,
      date: DateFormat('yyyy-MM-dd').format(widget.task.startTime),
      lecturesCompleted:
          widget.task.type == TaskType.study ? _lecturesCompleted : null,
      actualDurationMinutes: actualDurationMinutes,
      difficulty: widget.task.type == TaskType.study ? _difficulty : null,
      questionsAttempted:
          widget.task.type == TaskType.questions ? _questionsAttempted : null,
      subject: widget.task.subject,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    // Save to database
    final dbHelper = DatabaseHelper();
    await dbHelper.insertTaskLog(taskLog.toMap());

    // Update task status
    final updatedTask = Task(
      id: widget.task.id,
      date: widget.task.date,
      type: widget.task.type,
      name: widget.task.name,
      subject: widget.task.subject,
      startTime: widget.task.startTime,
      endTime: widget.task.endTime,
      durationMinutes: widget.task.durationMinutes,
      alarmSet: widget.task.alarmSet,
      alarmSound: widget.task.alarmSound,
      alarmTrigger: widget.task.alarmTrigger,
      notes: widget.task.notes,
      status:
          isPartial ? TaskStatus.inProgress : TaskStatus.completed,
      createdAt: widget.task.createdAt,
    );

    await dbHelper.updateTask(updatedTask.toMap());

    // Notify provider
    if (mounted) {
      context.read<DayPlannerProvider>().updateTask(updatedTask);
      widget.onComplete(taskLog);
      Navigator.pop(context);
    }
  }
}
