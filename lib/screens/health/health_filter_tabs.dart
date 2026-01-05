import 'package:flutter/material.dart';

class HealthFilterTabs extends StatelessWidget {
  final String currentFilter;
  final Function(String) onFilterChanged;

  const HealthFilterTabs({
    Key? key,
    required this.currentFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildBtn('day', 'Ngày'),
          const SizedBox(width: 8),
          _buildBtn('week', 'Tuần'),
          const SizedBox(width: 8),
          _buildBtn('month', 'Tháng'),
        ],
      ),
    );
  }

  Widget _buildBtn(String value, String label) {
    final isSelected = currentFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => onFilterChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
