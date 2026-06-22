import 'package:uuid/uuid.dart';

class DayReview {
  final String id;
  final String date; // YYYY-MM-DD format
  final String? wentWell;
  final String? didntGoWell;
  final String? tomorrowPriority;
  final DateTime createdAt;

  DayReview({
    String? id,
    required this.date,
    this.wentWell,
    this.didntGoWell,
    this.tomorrowPriority,
    DateTime? createdAt,
  })
  : id = id ?? const Uuid().v4(),
    createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'went_well': wentWell,
      'didnt_go_well': didntGoWell,
      'tomorrow_priority': tomorrowPriority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory DayReview.fromMap(Map<String, dynamic> map) {
    return DayReview(
      id: map['id'],
      date: map['date'],
      wentWell: map['went_well'],
      didntGoWell: map['didnt_go_well'],
      tomorrowPriority: map['tomorrow_priority'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
