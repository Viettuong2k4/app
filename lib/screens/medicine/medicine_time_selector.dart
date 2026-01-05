import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class MedicineTimeSelector extends StatelessWidget {
  final List<TimeOfDay> times;
  final Function(int) onRemove;
  final Function(int, TimeOfDay) onTimeChanged;
  final VoidCallback onAdd;

  const MedicineTimeSelector({
    Key? key,
    required this.times,
    required this.onRemove,
    required this.onTimeChanged,
    required this.onAdd,
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
              "Giờ uống",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
            ),
            Text(
              "${times.length}/5",
              style: const TextStyle(color: AppColors.gray500, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: times.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: times[index],
                        initialEntryMode: TimePickerEntryMode.input,
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              timePickerTheme: const TimePickerThemeData(
                                dayPeriodBorderSide: BorderSide(
                                  color: AppColors.blue500,
                                ),
                                dayPeriodColor: AppColors.blue50,
                                dayPeriodTextColor: AppColors.blue500,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) onTimeChanged(index, picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray300, width: 2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Lần ${index + 1}",
                            style: const TextStyle(color: AppColors.gray500),
                          ),
                          Row(
                            children: [
                              Text(
                                times[index].format(context),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gray900,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                LucideIcons.clock,
                                size: 18,
                                color: AppColors.blue500,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (times.length > 1) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => onRemove(index),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.red50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.red50),
                      ),
                      child: const Icon(
                        LucideIcons.trash2,
                        color: AppColors.red500,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        if (times.length < 5) ...[
          const SizedBox(height: 12),
          InkWell(
            onTap: onAdd,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.blue50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blue100),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    LucideIcons.plusCircle,
                    color: AppColors.blue500,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Thêm giờ uống",
                    style: TextStyle(
                      color: AppColors.blue600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
