import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:songkhoe/screens/health/health_chart.dart';
import 'package:songkhoe/screens/health/health_filter_tabs.dart';
import 'package:songkhoe/screens/health/health_history_list.dart';
import 'package:songkhoe/screens/health/health_summary_card.dart';
import '../../providers/health_provider.dart';

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

        final history = provider.getHistory(typeId);
        final latest = history.isNotEmpty ? history.first : null;

        // Chuẩn bị dữ liệu cho biểu đồ
        List<FlSpot> chartPoints = [];
        final chartData = history.take(7).toList().reversed.toList();

        if (chartData.isNotEmpty) {
          chartPoints = chartData.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble(), entry.value.value);
          }).toList();
        }

        double minY = 0;
        double maxY = 100;
        if (chartPoints.isNotEmpty) {
          final yValues = chartPoints.map((e) => e.y).toList()..sort();
          double minVal = yValues.first;
          double maxVal = yValues.last;
          double padding = (maxVal - minVal) == 0
              ? 10
              : (maxVal - minVal) * 0.2;
          minY = (minVal - padding).clamp(0, double.infinity);
          maxY = maxVal + padding;
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
                HealthSummaryCard(
                  value: latest != null ? latest.displayValue : "--",
                  unit: typeInfo['unit'],
                ),
                const SizedBox(height: 24),

                HealthFilterTabs(
                  currentFilter: _timeFilter,
                  onFilterChanged: (val) => setState(() => _timeFilter = val),
                ),
                const SizedBox(height: 24),

                chartPoints.isEmpty
                    ? Container(
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text("Chưa có dữ liệu biểu đồ"),
                      )
                    : HealthChart(points: chartPoints, minY: minY, maxY: maxY),

                const SizedBox(height: 24),

                HealthHistoryList(history: history, unit: typeInfo['unit']),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
