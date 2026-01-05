import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'dashboard_bmi_card.dart';
import 'dashboard_header.dart';
import 'dashboard_medicine_section.dart';
import 'dashboard_metric_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(
        context,
        listen: false,
      ).refreshData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).userName;

    return Consumer<DashboardProvider>(
      builder: (context, dashboard, child) {
        return Scaffold(
          backgroundColor: AppColors.gray50,
          body: RefreshIndicator(
            onRefresh: () => dashboard.refreshData(context),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: DashboardHeader(
                    userName: userName,
                    currentDateStr: dashboard.currentDateStr,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Chỉ số sức khỏe",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                        ),
                        // Nút xem tất cả (nếu cần)
                        // GestureDetector(
                        //   onTap: () {},
                        //   child: const Text("Xem tất cả", style: TextStyle(fontSize: 14, color: AppColors.blue500)),
                        // ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = dashboard.healthMetrics[index];

                      return DashboardMetricCard(
                        typeId: item['id'],
                        title: item['label'],
                        icon: item['icon'],
                        color: item['color'],
                      );
                    }, childCount: dashboard.healthMetrics.length),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.2,
                        ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        DashboardBmiCard(bmiValue: dashboard.bmi),
                        const SizedBox(height: 24),

                        DashboardMedicineSection(
                          takenCountText: dashboard.takenCountText,
                          progressPercentage: dashboard.progressPercentage,
                          medicines: dashboard.todayMedicines,
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
