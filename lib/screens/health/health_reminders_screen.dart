// File: lib/screens/health/health_reminders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/health_provider.dart';

class HealthRemindersScreen extends StatefulWidget {
  const HealthRemindersScreen({Key? key}) : super(key: key);

  @override
  State<HealthRemindersScreen> createState() => _HealthRemindersScreenState();
}

class _HealthRemindersScreenState extends State<HealthRemindersScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dữ liệu mới nhất khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthProvider>(context, listen: false).fetchSchedules();
    });
  }

  void _deleteSchedule(String docId, int notifId) async {
    try {
      await Provider.of<HealthProvider>(
        context,
        listen: false,
      ).deleteSchedule(docId, notifId);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Đã xóa lịch nhắc nhở")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e"), backgroundColor: AppColors.red500),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text("Quản lý nhắc nhở"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, provider, child) {
          final schedules = provider.schedules;

          if (schedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: AppColors.blue50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.bellOff,
                      size: 48,
                      color: AppColors.blue500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Chưa có lịch nhắc nhở nào",
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.gray500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: schedules.length,
            separatorBuilder: (ctx, i) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = schedules[index];
              final typeInfo = provider.getMetricType(item['typeId']);
              final label = typeInfo?['label'] ?? 'Chỉ số khác';
              final icon = typeInfo?['icon'] ?? LucideIcons.activity;
              final color = typeInfo?['color'] ?? AppColors.blue500;

              return Dismissible(
                key: Key(item['id']),
                direction: DismissDirection.endToStart,
                onDismissed: (_) {
                  _deleteSchedule(item['id'], item['notificationId']);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.red500,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.trash2, color: Colors.white),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (color as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Hàng ngày lúc ${item['time']}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.trash2,
                          color: AppColors.gray400,
                          size: 20,
                        ),
                        onPressed: () {
                          // Xác nhận xóa
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Xóa nhắc nhở?"),
                              content: const Text(
                                "Bạn sẽ không nhận được thông báo cho lịch này nữa.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text(
                                    "Hủy",
                                    style: TextStyle(color: AppColors.gray600),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _deleteSchedule(
                                      item['id'],
                                      item['notificationId'],
                                    );
                                  },
                                  child: const Text(
                                    "Xóa",
                                    style: TextStyle(
                                      color: AppColors.red500,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển sang màn hình THÊM lịch
          Navigator.pushNamed(context, '/add-health-schedule');
        },
        backgroundColor: AppColors.blue500,
        child: const Icon(LucideIcons.plus, color: Colors.white),
      ),
    );
  }
}
