import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/medicine_log_model.dart';
import '../../../core/constants/enums.dart';

class MedicineHistoryList extends StatelessWidget {
  final List<MedicineLogModel> history;

  const MedicineHistoryList({Key? key, required this.history})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lịch sử uống thuốc",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: history.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: AppColors.gray100),
            itemBuilder: (context, index) {
              final item = history[index];
              final isTaken = item.status == LogStatus.taken;
              final timeStr = DateFormat('HH:mm').format(item.scheduledTime);
              final dateStr = DateFormat('dd/MM').format(item.scheduledTime);

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      isTaken ? LucideIcons.checkCircle : LucideIcons.xCircle,
                      color: isTaken ? AppColors.green500 : AppColors.red500,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          timeStr,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isTaken ? AppColors.green50 : AppColors.red50,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        isTaken ? 'Đã uống' : 'Bỏ lỡ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isTaken
                              ? AppColors.green500
                              : AppColors.red500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
