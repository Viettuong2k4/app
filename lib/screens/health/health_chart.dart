import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';

class HealthChart extends StatelessWidget {
  final List<FlSpot> points;
  // Dữ liệu cho đường thứ 2 (Tâm trương)
  final List<FlSpot>? subPoints;
  final double minY;
  final double maxY;

  const HealthChart({
    Key? key,
    required this.points,
    this.subPoints,
    required this.minY,
    required this.maxY,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có dữ liệu phụ không để hiển thị chú thích
    final bool hasSubData = subPoints != null && subPoints!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Biểu đồ xu hướng",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              // Nếu có 2 đường thì hiển thị chú thích
              if (hasSubData)
                Row(
                  children: [
                    _buildLegend("Tâm thu", AppColors.blue500),
                    const SizedBox(width: 12),
                    _buildLegend("Tâm trương", AppColors.red500),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY - minY) > 10
                      ? (maxY - minY) / 4
                      : 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: const Color(0xFFF0F0F0),
                    strokeWidth: 1,
                    dashArray: [4, 4],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        // Logic hiển thị ngày (chỉ hiển thị số nguyên)
                        if (value % 1 == 0) return const SizedBox.shrink();
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 35,
                      interval: (maxY - minY) / 4, // Chia trục Y thành 4 khoảng
                      getTitlesWidget: (value, meta) {
                        if (value == minY || value == maxY)
                          return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Đường chính (Blue)
                  LineChartBarData(
                    spots: points,
                    isCurved: true,
                    color: AppColors.blue500,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.blue500.withOpacity(0.1),
                    ),
                  ),
                  // Đường phụ (Red) - Nếu có
                  if (hasSubData)
                    LineChartBarData(
                      spots: subPoints!,
                      isCurved: true,
                      color: AppColors.red500,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(show: false),
                    ),
                ],
                minY: minY,
                maxY: maxY,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.gray500),
        ),
      ],
    );
  }
}
