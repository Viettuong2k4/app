import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class MedicineInfoCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String frequency;
  final String times;

  const MedicineInfoCard({
    Key? key,
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.times,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.blueGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue500.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildRow("Liều lượng:", dosage),
          const SizedBox(height: 12),
          _buildRow("Tần suất:", frequency),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: AppColors.blue100),
              const SizedBox(width: 8),
              Text(
                times,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.blue100, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
