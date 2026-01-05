import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'auth_provider.dart';
import 'health_provider.dart';
import 'medicine_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final HealthProvider _health;
  final MedicineProvider _medicine;
  final AuthProvider? _auth;

  DashboardProvider(this._health, this._medicine, [this._auth]);

  bool get isLoading => _health.isLoading;

  String get currentDateStr {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final date = DateFormat('dd/MM').format(now);
    return "$dayName, $date";
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Thứ Hai';
      case 2:
        return 'Thứ Ba';
      case 3:
        return 'Thứ Tư';
      case 4:
        return 'Thứ Năm';
      case 5:
        return 'Thứ Sáu';
      case 6:
        return 'Thứ Bảy';
      case 7:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  String get bmi {
    final weightMetric = _health.getLatestMetric('weight');
    double weight = weightMetric?.value ?? _auth?.user?.weight ?? 0;
    double height = _auth?.user?.height ?? 0;

    if (weight > 0 && height > 0) {
      double hM = height / 100;
      double bmiVal = weight / (hM * hM);
      return bmiVal.toStringAsFixed(1);
    }
    return "--";
  }

  List<Map<String, dynamic>> get healthMetrics {
    final targetTypes = ['weight', 'bloodPressure', 'heartRate', 'bloodSugar'];

    List<Map<String, dynamic>> list = [];

    for (var typeId in targetTypes) {
      final config = _health.getMetricType(typeId);
      if (config == null) continue;

      final latest = _health.getLatestMetric(typeId);
      String valueStr = "--";

      if (latest != null) {
        valueStr = latest.displayValue;
      }

      list.add({
        'id': typeId,
        'label': config['label'],
        'icon': config['icon'],
        'color': config['color'],
        'unit': config['unit'],
        'value': valueStr,
      });
    }
    return list;
  }

  List<Map<String, dynamic>> get todayMedicines => _medicine.todayMedicines;

  String get takenCountText {
    final list = _medicine.todayMedicines;
    if (list.isEmpty) return "0/0";

    int taken = list.where((m) => m['status'] == 'taken').length;
    return "$taken/${list.length}";
  }

  double get progressPercentage {
    final list = _medicine.todayMedicines;
    if (list.isEmpty) return 0.0;

    int taken = list.where((m) => m['status'] == 'taken').length;
    return taken / list.length;
  }

  Future<void> refreshData(BuildContext context) async {
    if (_auth?.isAuthenticated == true) {
      await _auth?.fetchUserInfo(_auth!.user!.id);
    }
    _health.fetchRecords();
    _medicine.fetchData();
    notifyListeners();
  }
}
