import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class MedicineItem extends StatelessWidget {
  final String name;
  final String detail;
  final String status; // taken, late, missed, pending, none
  final bool showToggle;
  final VoidCallback onTap;
  final Function(bool)? onToggle;

  const MedicineItem({
    Key? key,
    required this.name,
    required this.detail,
    this.status = 'none',
    this.showToggle = false,
    required this.onTap,
    this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData iconMain = LucideIcons.pill;
    Color colorMain = AppColors.blue500;

    IconData checkIcon = LucideIcons.circle;
    Color checkColor = AppColors.gray300;
    bool isDone = false;

    switch (status) {
      case 'taken':
        iconMain = LucideIcons.checkCircle2;
        colorMain = AppColors.green500;
        checkIcon = LucideIcons.checkCircle2;
        checkColor = AppColors.green500;
        isDone = true;
        break;
      case 'late':
        iconMain = LucideIcons.alertCircle;
        colorMain = Colors.orange;
        checkIcon = LucideIcons.checkCircle2;
        checkColor = Colors.orange;
        isDone = true;
        break;
      case 'missed':
        iconMain = LucideIcons.xCircle;
        colorMain = AppColors.red500;
        break;
      case 'pending':
        iconMain = LucideIcons.clock;
        colorMain = AppColors.gray400;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon chính bên trái
              Icon(iconMain, color: colorMain, size: 32),
              const SizedBox(width: 16),

              // Nội dung text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.gray900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                    if (status == 'late')
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          "Đã uống trễ",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange[700],
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              if (showToggle && onToggle != null)
                InkWell(
                  onTap: () => onToggle!(!isDone),
                  borderRadius: BorderRadius.circular(24),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      isDone ? checkIcon : LucideIcons.circle,
                      size: 28,
                      color: isDone ? checkColor : AppColors.gray300,
                    ),
                  ),
                ),

              if (!showToggle)
                const Icon(
                  LucideIcons.chevronRight,
                  size: 20,
                  color: AppColors.gray400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
