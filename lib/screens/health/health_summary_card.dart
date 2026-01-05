import 'package:flutter/material.dart';

class HealthSummaryCard extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const HealthSummaryCard({
    Key? key,
    required this.value,
    required this.unit,
    this.label = "Giá trị hiện tại",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], // Blue 500 -> 600
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: const TextStyle(color: Color(0xFFDBEAFE), fontSize: 16),
          ),
        ],
      ),
    );
  }
}
