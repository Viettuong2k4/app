import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DashboardMedicineSection extends StatelessWidget {
  final String takenCountText;
  final double progressPercentage;
  final List<Map<String, dynamic>> medicines;

  const DashboardMedicineSection({
    Key? key,
    required this.takenCountText,
    required this.progressPercentage,
    required this.medicines,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Lịch uống thuốc",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray900,
              ),
            ),
            Text(
              takenCountText,
              style: const TextStyle(
                color: AppColors.blue500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progressPercentage,
            backgroundColor: AppColors.gray200,
            color: AppColors.blue500,
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: medicines.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text("Không có lịch uống thuốc hôm nay"),
                  ),
                )
              : Column(
                  children: medicines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final med = entry.value;
                    final isLast = index == medicines.length - 1;
                    return Column(
                      children: [
                        _buildMedicineItem(med),
                        if (!isLast)
                          const Divider(height: 1, color: AppColors.gray100),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildMedicineItem(Map<String, dynamic> med) {
    final status = med['status'];
    final isDone = status == 'taken';
    final isMissed = status == 'missed';

    IconData icon = Icons.access_time_rounded;
    Color color = AppColors.gray400;
    Color bgColor = AppColors.gray100;

    if (isDone) {
      icon = Icons.check_rounded;
      color = AppColors.green500;
      bgColor = AppColors.green50;
    } else if (isMissed) {
      icon = Icons.close_rounded;
      color = AppColors.red500;
      bgColor = AppColors.red50;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDone ? AppColors.gray400 : AppColors.gray900,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  med['singleTime'] ?? "",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
