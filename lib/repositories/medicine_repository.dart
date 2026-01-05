import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';

class MedicineRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'medicines';
  final String _logCollection = 'medicine_logs';

  Stream<List<MedicineModel>> getMedicines(String uid) {
    return _firestore
        .collection(_collection)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicineModel.fromFirestore(doc, null))
              .toList(),
        );
  }

  Future<String> addMedicine(MedicineModel medicine) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(medicine.toFirestore());
    return docRef.id;
  }

  Future<void> updateMedicine(MedicineModel medicine) async {
    await _firestore
        .collection(_collection)
        .doc(medicine.id)
        .update(medicine.toFirestore());
  }

  Future<void> deleteMedicine(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<MedicineLogModel>> getLogsByDate(String uid, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(_logCollection)
        .where(
          'scheduledTime',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicineLogModel.fromFirestore(doc, null))
              .toList(),
        );
  }

  Future<List<MedicineLogModel>> getHistoryForMedicine(
    String medicineId,
  ) async {
    final snapshot = await _firestore
        .collection(_logCollection)
        .where('medicineId', isEqualTo: medicineId)
        .orderBy('scheduledTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => MedicineLogModel.fromFirestore(doc, null))
        .toList();
  }

  Future<void> upsertLog(MedicineLogModel log) async {
    final query = await _firestore
        .collection(_logCollection)
        .where('medicineId', isEqualTo: log.medicineId)
        .where(
          'scheduledTime',
          isEqualTo: Timestamp.fromDate(log.scheduledTime),
        )
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      await query.docs.first.reference.update({
        'status': log.status.toJson(),
        'takenTime': log.takenTime != null
            ? Timestamp.fromDate(log.takenTime!)
            : null,
      });
    } else {
      await _firestore.collection(_logCollection).add(log.toFirestore());
    }
  }
}
