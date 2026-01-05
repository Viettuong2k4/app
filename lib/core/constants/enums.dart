// lib/core/constants/enums.dart

enum Gender {
  male,
  female,
  other;

  String toJson() => name;
  static Gender fromJson(String? json) =>
      values.firstWhere((e) => e.name == json, orElse: () => Gender.other);

  // Helper để hiển thị tiếng Việt
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Nam';
      case Gender.female:
        return 'Nữ';
      case Gender.other:
        return 'Khác';
    }
  }
}

enum HealthType {
  weight,
  bloodPressure,
  heartRate,
  bloodSugar,
  temperature,
  height,
  other;

  String toJson() => name;

  static HealthType fromJson(String? json) {
    // Thêm logic map thủ công nếu muốn hỗ trợ data cũ,
    // nhưng tốt nhất là dùng data mới chuẩn camelCase.
    return values.firstWhere(
      (e) => e.name == json,
      orElse: () => HealthType.other,
    );
  }

  String get displayName {
    switch (this) {
      case HealthType.weight:
        return 'Cân nặng';
      case HealthType.bloodPressure:
        return 'Huyết áp';
      case HealthType.heartRate:
        return 'Nhịp tim';
      case HealthType.bloodSugar:
        return 'Đường huyết';
      case HealthType.temperature:
        return 'Nhiệt độ';
      case HealthType.height:
        return 'Chiều cao';
      case HealthType.other:
        return 'Khác';
    }
  }
}

// Tần suất uống thuốc (Có thể mở rộng tùy logic app)
enum MedicineFrequency {
  daily,
  weekly,
  monthly,
  asNeeded;

  String toJson() => name;
  static MedicineFrequency fromJson(String? json) => values.firstWhere(
    (e) => e.name == json,
    orElse: () => MedicineFrequency.daily,
  );

  String get displayName {
    switch (this) {
      case MedicineFrequency.daily:
        return 'Hàng ngày';
      case MedicineFrequency.weekly:
        return 'Hàng tuần';
      case MedicineFrequency.monthly:
        return 'Hàng tháng';
      case MedicineFrequency.asNeeded:
        return 'Khi cần thiết';
    }
  }
}

enum LogStatus {
  pending,
  taken,
  missed,
  skipped,
  late;

  String toJson() => name;
  static LogStatus fromJson(String? json) =>
      values.firstWhere((e) => e.name == json, orElse: () => LogStatus.pending);
}
