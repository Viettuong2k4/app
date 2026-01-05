import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:songkhoe/screens/health/health_metric_item.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/health_provider.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({Key? key}) : super(key: key);

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthProvider>(context, listen: false).fetchRecords();
    });
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Bạn muốn làm gì?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.gray900,
              ),
            ),
            const SizedBox(height: 24),
            _buildMenuItem(
              context,
              icon: LucideIcons.plusCircle,
              color: AppColors.blue500,
              title: "Thêm kết quả đo",
              subtitle: "Nhập thủ công chỉ số sức khỏe mới",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add-health');
              },
            ),
            const SizedBox(height: 16),
            _buildMenuItem(
              context,
              icon: LucideIcons.alarmClock,
              color: AppColors.green500,
              title: "Quản lý hẹn giờ",
              subtitle: "Xem và quản lý lịch nhắc nhở",
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/health-reminders');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(LucideIcons.chevronRight, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              child: Row(
                children: [
                  if (Navigator.canPop(context))
                    IconButton(
                      icon: const Icon(
                        LucideIcons.arrowLeft,
                        color: AppColors.gray700,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  const Text(
                    "Sức khỏe",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.gray200),
            Expanded(
              child: Consumer<HealthProvider>(
                builder: (context, provider, child) {
                  final types = provider.metricTypes;

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: types.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final type = types[index];
                      final typeId = type['id'];
                      final latestRecord = provider.getLatestRecord(typeId);

                      // FIX: Sử dụng property của Model thay vì Map
                      final valueDisplay = latestRecord != null
                          ? "${latestRecord.displayValue} ${type['unit']}"
                          : "-- ${type['unit']}";

                      final statusInfo = _evaluateStatus(
                        typeId,
                        latestRecord?.value,
                      );

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: HealthMetricItem(
                          icon: type['icon'],
                          iconColor: type['color'],
                          iconBg: (type['color'] as Color).withOpacity(0.1),
                          name: type['label'],
                          value: valueDisplay,
                          status: statusInfo['text'],
                          statusColor: statusInfo['color'],
                          statusBg: (statusInfo['color'] as Color).withOpacity(
                            0.1,
                          ),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/health-detail',
                            arguments: {'typeId': typeId},
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: AppColors.blue500,
        child: const Icon(LucideIcons.plus, size: 24, color: Colors.white),
      ),
    );
  }

  Map<String, dynamic> _evaluateStatus(String typeId, double? value) {
    if (value == null) return {'text': "Chưa có", 'color': AppColors.gray400};

    // Logic đánh giá đơn giản (có thể mở rộng sau)
    if (typeId == 'weight') {
      if (value > 100) return {'text': "Cao", 'color': AppColors.red500};
    }
    if (typeId == 'heart_rate') {
      if (value > 100) return {'text': "Nhanh", 'color': AppColors.red500};
    }
    return {'text': "Ổn định", 'color': AppColors.green500};
  }
}
