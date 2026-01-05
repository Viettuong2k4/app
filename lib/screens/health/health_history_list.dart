import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/health_model.dart';

class HealthHistoryList extends StatelessWidget {
  final List<HealthMetricModel> history; // FIX TYPE
  final String unit;

  const HealthHistoryList({Key? key, required this.history, required this.unit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Lịch sử",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            color: Colors.white,
            child: history.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text("Chưa có dữ liệu")),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF3F4F6),
                    ),
                    itemBuilder: (context, index) {
                      final item = history[index];
                      // FIX: Truy cập property của Model
                      final timeStr = DateFormat('HH:mm').format(item.date);
                      final dateStr = DateFormat(
                        'dd/MM/yyyy',
                      ).format(item.date);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${item.displayValue} $unit",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF111827),
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "$dateStr • $timeStr",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
