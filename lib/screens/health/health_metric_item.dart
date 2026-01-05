import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HealthMetricItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String name;
  final String value;
  final String status;
  final Color statusColor;
  final Color statusBg;
  final VoidCallback onTap;

  const HealthMetricItem({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.name,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.gray900,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                status,
                style: TextStyle(fontSize: 12, color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
