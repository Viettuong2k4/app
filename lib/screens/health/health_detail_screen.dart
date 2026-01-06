import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:songkhoe/screens/health/health_chart.dart';
import 'package:songkhoe/screens/health/health_filter_tabs.dart';
import 'package:songkhoe/screens/health/health_history_list.dart';
import 'package:songkhoe/screens/health/health_summary_card.dart';
import '../../providers/health_provider.dart';
import '../../models/health_model.dart';

class HealthDetailScreen extends StatefulWidget {
  const HealthDetailScreen({Key? key}) : super(key: key);

  @override
  State<HealthDetailScreen> createState() => _HealthDetailScreenState();
}

class _HealthDetailScreenState extends State<HealthDetailScreen> {
  String _timeFilter = 'week';

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    final String typeId = args?['typeId'] ?? 'weight';

    return Consumer<HealthProvider>(
      builder: (context, provider, child) {
        final typeInfo = provider.getMetricType(typeId);
        if (typeInfo == null)
          return const Scaffold(body: Center(child: Text("Lỗi dữ liệu")));

        // toàn bộ lịch sử
        final history = provider.getHistory(typeId);
        final latest = history.isNotEmpty ? history.first : null;

        final now = DateTime.now();
        List<HealthMetricModel> filteredDescending = [];

        if (_timeFilter == 'day') {
          // Lọc trong ngày hôm nay
          filteredDescending = history.where((e) {
            return e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day;
          }).toList();
        } else if (_timeFilter == 'week') {
          // 7 ngày gần nhất
          final start = now.subtract(const Duration(days: 7));
          filteredDescending = history
              .where((e) => e.date.isAfter(start))
              .toList();
        } else if (_timeFilter == 'month') {
          // 30 ngày gần nhất
          final start = now.subtract(const Duration(days: 30));
          filteredDescending = history
              .where((e) => e.date.isAfter(start))
              .toList();
        } else {
          filteredDescending = List.from(history);
        }

        final chartData = filteredDescending.reversed.toList();

        List<FlSpot> chartPoints = [];
        // Dành cho chỉ số Tâm trương
        List<FlSpot>? subPoints;

        if (chartData.isNotEmpty) {
          chartPoints = chartData.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.value);
          }).toList();

          if (typeInfo['hasSubValue'] == true) {
            subPoints = chartData.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.subValue ?? 0.0);
            }).toList();
          }
        }

        // TÍNH TOÁN TRỤC Y (MIN/MAX)
        double minY = 0;
        double maxY = 100;

        if (chartPoints.isNotEmpty) {
          // Gom tất cả giá trị Y lại để tìm min/max
          final allY = chartPoints.map((e) => e.y).toList();
          if (subPoints != null) {
            allY.addAll(subPoints.map((e) => e.y));
          }
          // Sắp xếp để lấy min/max
          if (allY.isNotEmpty) {
            allY.sort();
            double minVal = allY.first;
            double maxVal = allY.last;

            double padding = (maxVal - minVal) == 0
                ? 10
                : (maxVal - minVal) * 0.2;

            minY = (minVal - padding).clamp(0, double.infinity);
            maxY = maxVal + padding;
          }
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Color(0xFF374151)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              typeInfo['label'],
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/add-health'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      children: const [
                        Icon(
                          LucideIcons.plus,
                          size: 20,
                          color: Color(0xFF3B82F6),
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Thêm",
                          style: TextStyle(
                            color: Color(0xFF3B82F6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card tổng quan chỉ số mới nhất
                HealthSummaryCard(
                  value: latest != null ? latest.displayValue : "--",
                  unit: typeInfo['unit'],
                ),
                const SizedBox(height: 24),

                // Bộ lọc thời gian (Ngày/Tuần/Tháng)
                HealthFilterTabs(
                  currentFilter: _timeFilter,
                  onFilterChanged: (val) => setState(() => _timeFilter = val),
                ),
                const SizedBox(height: 24),

                // Biểu đồ
                chartPoints.isEmpty
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          "Không có dữ liệu trong khoảng thời gian này",
                        ),
                      )
                    : HealthChart(
                        points: chartPoints,
                        subPoints: subPoints,
                        minY: minY,
                        maxY: maxY,
                      ),

                const SizedBox(height: 24),

                HealthHistoryList(
                  history: filteredDescending,
                  unit: typeInfo['unit'],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
