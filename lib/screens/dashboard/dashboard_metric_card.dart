import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/health_provider.dart';

class DashboardMetricCard extends StatelessWidget {
  final String typeId;
  final String title;
  final IconData icon;
  final Color color;

  const DashboardMetricCard({
    Key? key,
    required this.typeId,
    required this.title,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        final latestRecord = provider.getLatestRecord(typeId);
        final typeInfo = provider.getMetricType(typeId);
        final unit = typeInfo != null ? typeInfo['unit'] : '';

        String displayValue = "--";
        if (latestRecord != null) {
          displayValue = latestRecord.displayValue;
        }

        return InkWell(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/health-detail',
              arguments: {'typeId': typeId},
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: AppColors.gray400,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayValue,
                      style: const TextStyle(
                        fontSize: 20, // Số to
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray900,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
