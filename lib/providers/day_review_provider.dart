import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/day_review.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class DayReviewProvider extends ChangeNotifier {
  DayReview? _dayReview;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  DayReview? get dayReview => _dayReview;

  Future<void> loadReviewForDate(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final reviewMap = await _dbHelper.getDayReviewByDate(dateStr);
    if (reviewMap != null) {
      _dayReview = DayReview.fromMap(reviewMap);
    } else {
      _dayReview = null;
    }
    notifyListeners();
  }

  Future<void> saveReview(DateTime date, String wentWell, String didntGoWell, String tomorrowPriority) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final review = DayReview(
      date: dateStr,
      wentWell: wentWell.isEmpty ? null : wentWell,
      didntGoWell: didntGoWell.isEmpty ? null : didntGoWell,
      tomorrowPriority: tomorrowPriority.isEmpty ? null : tomorrowPriority,
    );
    await _dbHelper.insertDayReview(review.toMap());
    _dayReview = review;
    notifyListeners();
  }
}
