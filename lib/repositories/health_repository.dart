import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_model.dart';

class HealthRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<HealthMetricModel> get _metricsRef => _firestore
      .collection('health_metrics')
      .withConverter(
        fromFirestore: HealthMetricModel.fromFirestore,
        toFirestore: (model, _) => model.toFirestore(),
      );

  CollectionReference<Map<String, dynamic>> get _schedulesRef =>
      _firestore.collection('health_schedules');

  Stream<List<HealthMetricModel>> getHealthMetrics(String userId) {
    return _metricsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<void> addHealthMetric(HealthMetricModel metric) async {
    await _metricsRef.add(metric);
  }

  Future<void> deleteHealthMetric(String id) async {
    await _metricsRef.doc(id).delete();
  }

  Stream<List<Map<String, dynamic>>> getSchedules(String userId) {
    return _schedulesRef
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (s) => s.docs.map((d) {
            final data = d.data();
            data['id'] = d.id;
            return data;
          }).toList(),
        );
  }

  Future<String> addSchedule(Map<String, dynamic> data) async {
    final docRef = await _schedulesRef.add(data);
    return docRef.id;
  }

  Future<void> deleteSchedule(String id) async {
    await _schedulesRef.doc(id).delete();
  }
}
