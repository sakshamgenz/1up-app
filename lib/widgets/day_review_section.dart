import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/day_review.dart';
import '../providers/day_review_provider.dart';
import '../theme/app_theme.dart';

class DayReviewSection extends StatefulWidget {
  final DateTime selectedDate;

  const DayReviewSection({Key? key, required this.selectedDate})
      : super(key: key);

  @override
  State<DayReviewSection> createState() => _DayReviewSectionState();
}

class _DayReviewSectionState extends State<DayReviewSection> {
  late TextEditingController _wentWellController;
  late TextEditingController _didntGoWellController;
  late TextEditingController _tomorrowPriorityController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _wentWellController = TextEditingController();
    _didntGoWellController = TextEditingController();
    _tomorrowPriorityController = TextEditingController();
    _loadReview();
  }

  @override
  void didUpdateWidget(DayReviewSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _loadReview();
    }
  }

  void _loadReview() async {
    final provider = context.read<DayReviewProvider>();
    await provider.loadReviewForDate(widget.selectedDate);
    final review = provider.dayReview;
    if (review != null) {
      _wentWellController.text = review.wentWell ?? '';
      _didntGoWellController.text = review.didntGoWell ?? '';
      _tomorrowPriorityController.text = review.tomorrowPriority ?? '';
      setState(() => _isEditing = false);
    } else {
      _wentWellController.clear();
      _didntGoWellController.clear();
      _tomorrowPriorityController.clear();
      setState(() => _isEditing = true);
    }
  }

  @override
  void dispose() {
    _wentWellController.dispose();
    _didntGoWellController.dispose();
    _tomorrowPriorityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat('yyyy-MM-dd').format(widget.selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isPast = widget.selectedDate.isBefore(DateTime.now()) && !isToday;

    return Consumer<DayReviewProvider>(
      builder: (context, provider, _) {
        final hasReview = provider.dayReview != null;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Day Review',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText,
                    ),
                  ),
                  if (hasReview && isPast)
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isEditing || !hasReview) ...[_buildEditableView()],
              if (!_isEditing && hasReview) ...[_buildReadOnlyView()],
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditableView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReviewField('What went well today?', _wentWellController),
        const SizedBox(height: 12),
        _buildReviewField('What didn\'t go well?', _didntGoWellController),
        const SizedBox(height: 12),
        _buildReviewField('Tomorrow\'s top priority?', _tomorrowPriorityController),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Save Review'),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyView() {
    final review = context.read<DayReviewProvider>().dayReview!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (review.wentWell != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What went well today?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.wentWell!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        if (review.didntGoWell != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'What didn\'t go well?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.didntGoWell!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        if (review.tomorrowPriority != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tomorrow\'s top priority?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  review.tomorrowPriority!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildReviewField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: _isEditing || context.read<DayReviewProvider>().dayReview == null,
          maxLines: 2,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            contentPadding: const EdgeInsets.all(12),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  void _saveReview() async {
    await context.read<DayReviewProvider>().saveReview(
      widget.selectedDate,
      _wentWellController.text,
      _didntGoWellController.text,
      _tomorrowPriorityController.text,
    );

    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review saved successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
