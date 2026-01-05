import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medicine_model.dart';
import '../models/medicine_log_model.dart';
import '../core/constants/enums.dart';
import '../repositories/medicine_repository.dart';
import '../services/notification_service.dart';

class MedicineProvider extends ChangeNotifier {
  final MedicineRepository _repository = MedicineRepository();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  List<MedicineModel> _medicines = [];
  List<MedicineLogModel> _todayLogs = [];

  List<MedicineModel> get medicines => _medicines;

  void fetchData() {
    final user = _auth.currentUser;
    if (user != null) {
      _repository.getMedicines(user.uid).listen((data) {
        _medicines = data;
        _checkAndCancelExpiredMedicines(data);
        notifyListeners();
      });
      _repository.getLogsByDate(user.uid, DateTime.now()).listen((data) {
        _todayLogs = data;
        notifyListeners();
      });
    }
  }

  void _checkAndCancelExpiredMedicines(List<MedicineModel> medicines) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    for (final med in medicines) {
      if (med.endDate != null && med.endDate!.isBefore(todayStart)) {
        _cancelReminders(med);
      }
    }
  }

  List<Map<String, dynamic>> get todayMedicines {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    final activeMedicines = _medicines.where((m) {
      final isStarted = !m.startDate.isAfter(
        todayStart.add(const Duration(days: 1)),
      );
      final isNotEnded = m.endDate == null || !m.endDate!.isBefore(todayStart);
      return isStarted && isNotEnded;
    });

    final list = activeMedicines
        .expand(
          (m) => m.times.map((timeStr) {
            final parts = timeStr.split(':');
            final scheduledTime = DateTime(
              today.year,
              today.month,
              today.day,
              int.parse(parts[0]),
              int.parse(parts[1]),
            );

            final log = _todayLogs.firstWhere(
              (l) =>
                  l.medicineId == m.id &&
                  l.scheduledTime.year == scheduledTime.year &&
                  l.scheduledTime.month == scheduledTime.month &&
                  l.scheduledTime.day == scheduledTime.day &&
                  l.scheduledTime.hour == scheduledTime.hour &&
                  l.scheduledTime.minute == scheduledTime.minute,
              orElse: () => MedicineLogModel(
                id: 'dummy',
                medicineId: m.id,
                scheduledTime: scheduledTime,
                status: LogStatus.pending,
              ),
            );

            return {
              'id': m.id,
              'name': m.name,
              'dosage': m.dosage,
              'singleTime': timeStr,
              'status': log.status.name,
              'frequency': m.frequency.displayName,
              'uniqueKey': "${m.id}_$timeStr",
            };
          }),
        )
        .toList();

    list.sort(
      (a, b) =>
          (a['singleTime'] as String).compareTo(b['singleTime'] as String),
    );
    return list;
  }

  int _generateNotificationId(String medicineId, String timeStr) {
    return "${medicineId}_$timeStr".hashCode & 0x7FFFFFFF;
  }

  Future<void> _scheduleReminders(MedicineModel medicine) async {
    if (!medicine.note.contains("Đã bật nhắc nhở")) return;

    for (var timeStr in medicine.times) {
      final parts = timeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final notifId = _generateNotificationId(medicine.id, timeStr);

      await _notificationService.scheduleMedicineReminder(
        id: notifId,
        title: "💊 Đã đến giờ uống thuốc!",
        body: "${medicine.name} - ${medicine.dosage}",
        hour: hour,
        minute: minute,
      );
    }
  }

  Future<void> _cancelReminders(MedicineModel medicine) async {
    for (var timeStr in medicine.times) {
      final notifId = _generateNotificationId(medicine.id, timeStr);
      await _notificationService.cancelNotification(notifId);
    }
  }

  Future<void> addMedicine({
    required String name,
    required String dosage,
    required List<String> times,
    required String frequency,
    required String note,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final med = MedicineModel(
      id: '',
      uid: user.uid,
      name: name,
      dosage: dosage,
      times: times,
      frequency: MedicineFrequency.daily,
      note: note,
      startDate: startDate,
      endDate: endDate,
    );

    final newId = await _repository.addMedicine(med);

    final newMed = MedicineModel(
      id: newId,
      uid: user.uid,
      name: name,
      dosage: dosage,
      times: times,
      frequency: MedicineFrequency.daily,
      note: note,
      startDate: startDate,
      endDate: endDate,
    );

    await _scheduleReminders(newMed);
  }

  Future<void> updateMedicine({
    required String id,
    required String name,
    required String dosage,
    required List<String> times,
    required String frequency,
    required String note,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final oldMed = getMedicineById(id);
    if (oldMed != null) await _cancelReminders(oldMed);

    final med = MedicineModel(
      id: id,
      uid: user.uid,
      name: name,
      dosage: dosage,
      times: times,
      frequency: MedicineFrequency.daily,
      note: note,
      startDate: startDate,
      endDate: endDate,
    );

    await _repository.updateMedicine(med);
    await _scheduleReminders(med);
  }

  Future<void> deleteMedicine(String id) async {
    final med = getMedicineById(id);
    if (med != null) await _cancelReminders(med);
    await _repository.deleteMedicine(id);
  }

  MedicineModel? getMedicineById(String id) {
    for (final item in _medicines) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<List<MedicineLogModel>> getHistoryForMedicine(
    String medicineId,
  ) async {
    return await _repository.getHistoryForMedicine(medicineId);
  }

  Future<void> changeStatus(
    String medicineId,
    String timeSlot,
    String statusStr,
  ) async {
    final now = DateTime.now();
    final parts = timeSlot.split(':');
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );

    LogStatus status = LogStatus.pending;
    for (final s in LogStatus.values) {
      if (s.name == statusStr) {
        status = s;
        break;
      }
    }

    final log = MedicineLogModel(
      id: '',
      medicineId: medicineId,
      scheduledTime: scheduledTime,
      takenTime: status == LogStatus.taken ? DateTime.now() : null,
      status: status,
    );

    await _repository.upsertLog(log);
  }
}
