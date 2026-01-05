import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:songkhoe/core/constants/enums.dart';

class MedicineModel {
  final String id;
  final String uid;
  final String name;
  final String dosage;
  final List<String> times;
  final MedicineFrequency frequency;
  final String note;
  final DateTime startDate;
  final DateTime? endDate;

  MedicineModel({
    required this.id,
    required this.uid,
    required this.name,
    required this.dosage,
    required this.times,
    required this.frequency,
    this.note = '',
    required this.startDate,
    this.endDate,
  });

  factory MedicineModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception("Data is null");

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return MedicineModel(
      id: snapshot.id,
      uid: data['uid']?.toString() ?? '',
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      times: List<String>.from(data['times'] ?? []),
      frequency: MedicineFrequency.fromJson(data['frequency']),
      note: data['note'] ?? '',
      startDate: parseDate(data['startDate']),
      endDate: data['endDate'] != null ? parseDate(data['endDate']) : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'dosage': dosage,
      'times': times,
      'frequency': frequency.toJson(),
      'note': note,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    };
  }
}
