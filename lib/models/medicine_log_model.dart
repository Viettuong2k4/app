import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:songkhoe/core/constants/enums.dart';

class MedicineLogModel {
  final String id;
  final String medicineId;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final LogStatus status;

  MedicineLogModel({
    required this.id,
    required this.medicineId,
    required this.scheduledTime,
    this.takenTime,
    this.status = LogStatus.pending,
  });

  factory MedicineLogModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    if (data == null) throw Exception("Data is null");

    return MedicineLogModel(
      id: snapshot.id,
      medicineId: data['medicineId']?.toString() ?? '',
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      takenTime: (data['takenTime'] as Timestamp?)?.toDate(),
      status: LogStatus.fromJson(data['status']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicineId': medicineId,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'takenTime': takenTime != null ? Timestamp.fromDate(takenTime!) : null,
      'status': status.toJson(),
    };
  }
}
