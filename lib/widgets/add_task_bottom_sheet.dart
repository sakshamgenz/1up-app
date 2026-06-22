import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/day_planner_provider.dart';
import '../utils/utils.dart';
import '../theme/app_theme.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final DateTime selectedDate;

  const AddTaskBottomSheet({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  late TaskType _selectedType;
  late Subject _selectedSubject;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _durationHours;
  late int _durationMinutes;
  bool _useDuration = true;
  bool _alarmSet = false;
  late String _alarmSound;
  late AlarmTrigger _alarmTrigger;

  final _taskNameController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedType = TaskType.study;
    _selectedSubject = Subject.physics;
    _startTime = TimeOfDay.now();
    _endTime = _startTime.replacing(hour: _startTime.hour + 1);
    _durationHours = 1;
    _durationMinutes = 0;
    _alarmSound = 'Digital Beep';
    _alarmTrigger = AlarmTrigger.fiveMinutesBefore;
  }

  @override
  void dispose() {
    _taskNameController.dispose();
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
            const Text(
              'Add Task',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildTaskTypeSelector(),
            const SizedBox(height: 20),
            _buildTextField('Task Name', _taskNameController),
            const SizedBox(height: 20),
            if (_selectedType == TaskType.study ||
                _selectedType == TaskType.questions)
              ...[_buildSubjectSelector(), const SizedBox(height: 20)],
            _buildTimeSelector(),
            const SizedBox(height: 20),
            _buildDurationToggle(),
            const SizedBox(height: 20),
            _buildAlarmSettings(),
            const SizedBox(height: 20),
            _buildTextField('Notes (Optional)', _notesController,
                maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Task'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Task Type',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: TaskType.values.map((type) {
            final isSelected = _selectedType == type;
            return GestureDetector(
              onTap: () => setState(() => _selectedType = type),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TaskTypeUtils.getColor(type).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(
                              color: TaskTypeUtils.getColor(type), width: 2)
                          : null,
                    ),
                    child: Icon(
                      TaskTypeUtils.getIcon(type),
                      color: TaskTypeUtils.getColor(type),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TaskTypeUtils.getLabel(type),
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Subject', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButton<Subject>(
          value: _selectedSubject,
          isExpanded: true,
          items: Subject.values.map((subject) {
            return DropdownMenuItem(
              value: subject,
              child: Text(SubjectUtils.getLabel(subject)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedSubject = value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Start Time',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectTime(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange.withOpacity(0.1),
                  foregroundColor: AppColors.accentOrange,
                ),
                child: Text(TimeUtils.formatTime(_timeOfDayToDateTime(_startTime))),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('End Time',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _selectTime(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentOrange.withOpacity(0.1),
                  foregroundColor: AppColors.accentOrange,
                ),
                child: Text(TimeUtils.formatTime(_timeOfDayToDateTime(_endTime))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _useDuration ? 'Duration' : 'Deadline',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Switch(
              value: _useDuration,
              onChanged: (value) => setState(() => _useDuration = value),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_useDuration)
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
                  ),
                  onChanged: (value) {
                    setState(
                        () => _durationHours = int.tryParse(value) ?? 1);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Minutes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(
                        () => _durationMinutes = int.tryParse(value) ?? 0);
                  },
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildAlarmSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: const Text('Set Alarm',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            Switch(
              value: _alarmSet,
              onChanged: (value) => setState(() => _alarmSet = value),
            ),
          ],
        ),
        if (_alarmSet) ...[const SizedBox(height: 12)],
      ],
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  DateTime _timeOfDayToDateTime(TimeOfDay time) {
    return DateTime(2024, 1, 1, time.hour, time.minute);
  }

  void _saveTask() {
    if (_taskNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task name')),
      );
      return;
    }

    final startDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    DateTime endDateTime;
    if (_useDuration) {
      endDateTime = startDateTime.add(
        Duration(hours: _durationHours, minutes: _durationMinutes),
      );
    } else {
      endDateTime = DateTime(
        widget.selectedDate.year,
        widget.selectedDate.month,
        widget.selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );
    }

    final durationMinutes =
        endDateTime.difference(startDateTime).inMinutes;

    final task = Task(
      date: DateFormat('yyyy-MM-dd').format(widget.selectedDate),
      type: _selectedType,
      name: _taskNameController.text,
      subject: (_selectedType == TaskType.study ||
              _selectedType == TaskType.questions)
          ? _selectedSubject
          : null,
      startTime: startDateTime,
      endTime: endDateTime,
      durationMinutes: durationMinutes,
      alarmSet: _alarmSet,
      alarmSound: _alarmSet ? _alarmSound : null,
      alarmTrigger: _alarmSet ? _alarmTrigger : null,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    context.read<DayPlannerProvider>().addTask(task);
    Navigator.pop(context);
  }
}
