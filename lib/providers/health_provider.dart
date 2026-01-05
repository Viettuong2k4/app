import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/health_model.dart';
import '../core/constants/enums.dart';
import '../repositories/health_repository.dart';
import '../services/notification_service.dart';

class HealthProvider extends ChangeNotifier {
  final HealthRepository _repository = HealthRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  List<HealthMetricModel> _metrics = [];
  List<Map<String, dynamic>> _schedules = [];
  bool _isLoading = false;

  final List<Map<String, dynamic>> _metricTypes = [
    {
      'id': 'weight',
      'label': 'Cân nặng',
      'unit': 'kg',
      'icon': LucideIcons.scale,
      'color': Colors.blue,
      'hasSubValue': false,
    },
    {
      'id': 'bloodPressure',
      'label': 'Huyết áp',
      'unit': 'mmHg',
      'icon': LucideIcons.heart,
      'color': Colors.red,
      'hasSubValue': true,
      'subLabel': 'Tâm trương',
      'mainLabel': 'Tâm thu',
    },
    {
      'id': 'heartRate',
      'label': 'Nhịp tim',
      'unit': 'bpm',
      'icon': LucideIcons.activity,
      'color': Colors.orange,
      'hasSubValue': false,
    },
    {
      'id': 'bloodSugar',
      'label': 'Đường huyết',
      'unit': 'mg/dL',
      'icon': LucideIcons.droplet,
      'color': Colors.purple,
      'hasSubValue': false,
    },
  ];

  List<HealthMetricModel> get metrics => _metrics;
  List<Map<String, dynamic>> get metricTypes => _metricTypes;
  List<Map<String, dynamic>> get schedules => _schedules;
  bool get isLoading => _isLoading;

  void fetchRecords() {
    final user = _auth.currentUser;
    if (user != null) {
      _repository.getHealthMetrics(user.uid).listen((data) {
        _metrics = data;
        notifyListeners();
      });
    }
  }

  void fetchSchedules() {
    final user = _auth.currentUser;
    if (user != null) {
      _repository.getSchedules(user.uid).listen((data) {
        _schedules = data;
        notifyListeners();
      });
    }
  }

  Future<void> addRecord({
    required String typeId,
    required double value,
    double? subValue,
    required DateTime date,
    String? note,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final metric = HealthMetricModel(
      id: '',
      userId: user.uid,
      type: HealthType.fromJson(typeId),
      value: value,
      subValue: subValue,
      date: date,
      note: note,
    );

    await _repository.addHealthMetric(metric);
  }

  Future<void> addSchedule({
    required String typeId,
    required TimeOfDay time,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final String uniqueKey =
        "${user.uid}_${typeId}_${time.hour}_${time.minute}";
    final int notificationId = uniqueKey.hashCode & 0x7FFFFFFF;

    final timeStr =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    await _repository.addSchedule({
      'userId': user.uid,
      'typeId': typeId,
      'time': timeStr,
      'isActive': true,
      'notificationId': notificationId,
    });

    final typeInfo = getMetricType(typeId);
    final String label = typeInfo?['label'] ?? 'Sức khỏe';

    await _notificationService.scheduleHealthReminder(
      id: notificationId,
      title: "Đến giờ đo $label",
      body: "Đã đến giờ kiểm tra $label. Hãy dành chút thời gian để đo nhé!",
      hour: time.hour,
      minute: time.minute,
    );

    fetchSchedules();
  }

  Future<void> deleteSchedule(String docId, int notifId) async {
    await _notificationService.cancelNotification(notifId);
    await _repository.deleteSchedule(docId);
  }

  HealthMetricModel? getLatestRecord(String typeId) {
    final targetType = HealthType.fromJson(typeId);
    final list = _metrics.where((m) => m.type == targetType).toList();
    if (list.isEmpty) return null;
    return list.first;
  }

  HealthMetricModel? getLatestMetric(String typeId) => getLatestRecord(typeId);

  List<HealthMetricModel> getHistory(String typeId) {
    final targetType = HealthType.fromJson(typeId);
    return _metrics.where((m) => m.type == targetType).toList();
  }

  Map<String, dynamic>? getMetricType(String typeId) {
    try {
      return _metricTypes.firstWhere((t) => t['id'] == typeId);
    } catch (_) {
      return null;
    }
  }

  void clearData() {
    _metrics = [];
    _schedules = [];
    notifyListeners();
  }
}
