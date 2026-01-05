import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DashboardBmiCard extends StatelessWidget {
  final String bmiValue;

  const DashboardBmiCard({Key? key, required this.bmiValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.green50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: AppColors.green500,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "BMI (Chỉ số khối cơ thể)",
                  style: TextStyle(fontSize: 14, color: AppColors.gray600),
                ),
                Text(
                  "$bmiValue (Bình thường)",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
