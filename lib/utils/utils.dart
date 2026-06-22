import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskTypeUtils {
  static IconData getIcon(TaskType type) {
    switch (type) {
      case TaskType.study:
        return Icons.menu_book;
      case TaskType.questions:
        return Icons.edit;
      case TaskType.break_:
        return Icons.local_cafe;
      case TaskType.sleep:
        return Icons.bedtime;
      case TaskType.wasteTime:
        return Icons.phone;
    }
  }

  static Color getColor(TaskType type) {
    switch (type) {
      case TaskType.study:
        return const Color(0xFF3B82F6);
      case TaskType.questions:
        return const Color(0xFFD97706);
      case TaskType.break_:
        return const Color(0xFF8B5CF6);
      case TaskType.sleep:
        return const Color(0xFF1E3A5F);
      case TaskType.wasteTime:
        return const Color(0xFFEF4444);
    }
  }

  static String getLabel(TaskType type) {
    switch (type) {
      case TaskType.study:
        return 'Study/Lecture';
      case TaskType.questions:
        return 'Questions';
      case TaskType.break_:
        return 'Break';
      case TaskType.sleep:
        return 'Sleep';
      case TaskType.wasteTime:
        return 'Waste Time';
    }
  }
}

class SubjectUtils {
  static String getLabel(Subject subject) {
    switch (subject) {
      case Subject.physics:
        return 'Physics';
      case Subject.chemistry:
        return 'Chemistry';
      case Subject.mathematics:
        return 'Mathematics';
      case Subject.other:
        return 'Other';
    }
  }

  static Color getColor(Subject subject) {
    switch (subject) {
      case Subject.physics:
        return const Color(0xFF3B82F6);
      case Subject.chemistry:
        return const Color(0xFF10B981);
      case Subject.mathematics:
        return const Color(0xFFD97706);
      case Subject.other:
        return const Color(0xFF6B7280);
    }
  }
}

class TimeUtils {
  static String formatTime(DateTime time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) {
      return '${mins}m';
    } else if (mins == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${mins}m';
    }
  }

  static String formatDateForDisplay(DateTime date) {
    final weekDay = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$weekDay, $day $month';
  }

  static String getMonthYear(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String getWeekRange(DateTime startDate) {
    final endDate = startDate.add(const Duration(days: 6));
    return '${startDate.day} - ${endDate.day} ${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][endDate.month - 1]}';
  }
}
