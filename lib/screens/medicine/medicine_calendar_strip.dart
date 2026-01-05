import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MedicineCalendarStrip extends StatelessWidget {
  const MedicineCalendarStrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    // Mock logic: Giả sử hôm nay là T4 (index 3)
    final selectedIndex = 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lịch uống thuốc",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.gray900,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(days.length, (index) {
              final isSelected = index == selectedIndex;
              return Container(
                width: 48,
                height: 64,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.blue50 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.blue500 : AppColors.gray200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppColors.blue500
                            : AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${18 + index}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.blue500
                            : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
