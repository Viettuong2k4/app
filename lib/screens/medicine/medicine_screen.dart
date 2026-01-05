import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:songkhoe/screens/medicine/medicine_item.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine_model.dart';
import 'package:intl/intl.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({Key? key}) : super(key: key);

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  String _activeTab = 'today';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MedicineProvider>(context, listen: false).fetchData();
    });
  }

  String? _determineStatusForSingleTime(
    String targetTime,
    BuildContext context,
  ) {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    try {
      final parts = targetTime.trim().split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final targetMinutes = hour * 60 + minute;

      final diff = currentMinutes - targetMinutes;

      if (diff >= -30 && diff <= 15) {
        return 'taken';
      }

      if (diff > 15 && diff <= 60) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Ghi nhận uống trễ (trong vòng 1h)"),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
        return 'late';
      }

      if (diff > 60) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã quá giờ uống thuốc hơn 1 tiếng!"),
            backgroundColor: AppColors.red500,
          ),
        );
        return null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chưa tới giờ uống thuốc!"),
          backgroundColor: AppColors.gray500,
        ),
      );
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thuốc",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton("Hôm nay", 'today'),
                        _buildTabButton("Tất cả", 'all'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.gray200),
            Expanded(
              child: Consumer<MedicineProvider>(
                builder: (context, provider, child) {
                  final isTodayTab = _activeTab == 'today';

                  final List<dynamic> listData = isTodayTab
                      ? provider.todayMedicines
                      : provider.medicines;

                  if (listData.isEmpty)
                    return const Center(child: Text("Chưa có thuốc nào"));

                  return ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: listData.length,
                    separatorBuilder: (ctx, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = listData[index];

                      String name = '';
                      String detail = '';
                      String status = 'none';
                      String id = '';
                      bool showToggle = false;

                      if (isTodayTab) {
                        final map = item as Map<String, dynamic>;
                        id = map['id'];
                        name = map['name'];
                        detail = "${map['dosage']} • ${map['singleTime']}";
                        status = map['status'];
                        showToggle = true;
                      } else {
                        final model = item as MedicineModel;
                        id = model.id;
                        name = model.name;

                        final dateFormat = DateFormat('dd/MM/yyyy');
                        String durationStr;

                        if (model.endDate == null) {
                          durationStr = "Hàng ngày";
                        } else {
                          final start = dateFormat.format(model.startDate);
                          final end = dateFormat.format(model.endDate!);
                          durationStr = "$start - $end";
                        }

                        detail = "${model.dosage} • $durationStr";

                        status = 'none';
                        showToggle = false;
                      }

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: MedicineItem(
                          name: name,
                          detail: detail,
                          status: status,
                          showToggle: showToggle,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/medicine-detail',
                              arguments: {'id': id},
                            );
                          },
                          onToggle: (val) {
                            if (!isTodayTab) return;
                            final map = item as Map<String, dynamic>;
                            final currentTimeSlot = map['singleTime'];

                            if (map['status'] == 'taken' ||
                                map['status'] == 'late') {
                              provider.changeStatus(
                                id,
                                currentTimeSlot,
                                'pending',
                              );
                            } else {
                              final newStatus = _determineStatusForSingleTime(
                                currentTimeSlot,
                                context,
                              );
                              if (newStatus != null) {
                                provider.changeStatus(
                                  id,
                                  currentTimeSlot,
                                  newStatus,
                                );
                              }
                            }
                          },
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
        onPressed: () => Navigator.pushNamed(context, '/add-medicine'),
        backgroundColor: AppColors.blue500,
        child: const Icon(LucideIcons.plus, size: 24),
      ),
    );
  }

  Widget _buildTabButton(String title, String key) {
    final isActive = _activeTab == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.gray900 : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }
}
