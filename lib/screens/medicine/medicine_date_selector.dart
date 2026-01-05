import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';

class MedicineDateSelector extends StatelessWidget {
  final DateTime startDate;
  final DateTime? endDate;
  final Function(DateTime) onStartDateChanged;
  final Function(DateTime) onEndDateChanged;

  const MedicineDateSelector({
    Key? key,
    required this.startDate,
    this.endDate,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
  }) : super(key: key);

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? startDate : (endDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isStart)
        onStartDateChanged(picked);
      else
        onEndDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildDateItem(context, "Ngày bắt đầu", startDate, true),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDateItem(context, "Ngày kết thúc", endDate, false),
        ),
      ],
    );
  }

  Widget _buildDateItem(
    BuildContext context,
    String label,
    DateTime? date,
    bool isStart,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray700,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickDate(context, isStart),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray300, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : "--/--/----",
                  style: TextStyle(
                    fontSize: 16,
                    color: date != null ? AppColors.gray900 : AppColors.gray400,
                  ),
                ),
                Icon(LucideIcons.calendar, size: 18, color: AppColors.gray400),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
