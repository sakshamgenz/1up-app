import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/day_planner_provider.dart';
import '../theme/app_theme.dart';
import '../utils/utils.dart';
import '../widgets/task_card.dart';
import '../widgets/add_task_bottom_sheet.dart';

class DayPlannerScreen extends StatefulWidget {
  const DayPlannerScreen({Key? key}) : super(key: key);

  @override
  State<DayPlannerScreen> createState() => _DayPlannerScreenState();
}

class _DayPlannerScreenState extends State<DayPlannerScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Consumer<DayPlannerProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildTimeline(provider),
                _buildDayReviewSection(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskBottomSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.background,
      title: const Text('27'),
      centerTitle: false,
      actions: [
        Consumer<DayPlannerProvider>(
          builder: (context, provider, _) {
            return Expanded(
              child: Center(
                child: Text(
                  TimeUtils.formatDateForDisplay(provider.selectedDate),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimeline(DayPlannerProvider provider) {
    final timeSlots = _generateTimeSlots();
    final tasks = provider.tasks;
    final now = DateTime.now();
    final isToday = DateFormat('yyyy-MM-dd').format(provider.selectedDate) ==
        DateFormat('yyyy-MM-dd').format(now);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time labels on the left
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: timeSlots.map((time) {
              return Container(
                height: 60,
                width: 50,
                alignment: Alignment.center,
                child: Text(
                  TimeUtils.formatTime(time),
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
          // Timeline and tasks on the right
          Expanded(
            child: Stack(
              children: [
                // Background timeline
                Column(
                  children: List.generate(
                    timeSlots.length,
                    (index) => Container(
                      height: 60,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.divider,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Current time indicator
                if (isToday)
                  Positioned(
                    top: _getTimelineOffset(now),
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      color: Colors.red,
                      child: const Align(
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          radius: 6,
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ),
                // Task cards
                Column(
                  children: tasks.map((task) {
                    return Positioned(
                      top: _getTimelineOffset(task.startTime),
                      child: _buildTaskCard(task, context, provider),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task, BuildContext context, DayPlannerProvider provider) {
    return TaskCard(
      task: task,
      onTap: () => _showTaskCompletionSheet(context, task),
      onDelete: () => provider.deleteTask(task.id),
    );
  }

  Widget _buildDayReviewSection() {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Day Review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          _buildReviewField('What went well today?'),
          const SizedBox(height: 12),
          _buildReviewField('What didn\'t go well?'),
          const SizedBox(height: 12),
          _buildReviewField('Tomorrow\'s top priority?'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentOrange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Review'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewField(String label) {
    return TextField(
      decoration: InputDecoration(
        hintText: label,
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        contentPadding: const EdgeInsets.all(12),
      ),
      maxLines: 2,
    );
  }

  List<DateTime> _generateTimeSlots() {
    final slots = <DateTime>[];
    final date = DateTime(2024, 1, 1); // arbitrary date
    for (int i = 6; i < 24; i++) {
      slots.add(DateTime(date.year, date.month, date.day, i));
    }
    return slots;
  }

  double _getTimelineOffset(DateTime time) {
    final startHour = 6;
    final offsetHours = time.hour - startHour + (time.minute / 60);
    return offsetHours * 60;
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddTaskBottomSheet(
        selectedDate: context.read<DayPlannerProvider>().selectedDate,
      ),
    );
  }

  void _showTaskCompletionSheet(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(),
    );
  }
}
