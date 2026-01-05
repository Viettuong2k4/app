import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/enums.dart';

class HealthMetricModel {
  final String id;
  final String userId;
  final HealthType type;
  final double value;
  final double? subValue;
  final DateTime date;
  final String? note;

  HealthMetricModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.value,
    this.subValue,
    required this.date,
    this.note,
  });

  String get displayValue {
    String mainVal = (value % 1 == 0)
        ? value.toInt().toString()
        : value.toStringAsFixed(1);

    if (subValue != null && subValue! > 0) {
      String subVal = (subValue! % 1 == 0)
          ? subValue!.toInt().toString()
          : subValue!.toStringAsFixed(1);
      return "$mainVal/$subVal";
    }
    return mainVal;
  }

  factory HealthMetricModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception("Data is null");

    return HealthMetricModel(
      id: snapshot.id,
      userId: data['userId']?.toString() ?? '',
      type: HealthType.fromJson(data['type']),
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      subValue: (data['subValue'] as num?)?.toDouble(),
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: data['note'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toJson(),
      'value': value,
      'subValue': subValue,
      'date': Timestamp.fromDate(date),
      'note': note,
    };
  }
}
