import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:songkhoe/screens/medicine/medicine_history_list.dart';
import 'package:songkhoe/screens/medicine/medicine_info_card.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/medicine_provider.dart';
import '../../models/medicine_log_model.dart';

class MedicineDetailScreen extends StatelessWidget {
  const MedicineDetailScreen({Key? key}) : super(key: key);

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xóa thuốc?"),
        content: const Text("Hành động này không thể hoàn tác."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<MedicineProvider>(
                context,
                listen: false,
              ).deleteMedicine(id);

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    String startStr = dateFormat.format(start);
    if (end == null) return 'Hàng ngày';
    String endStr = dateFormat.format(end);
    return "$startStr - $endStr";
  }

  @override
  Widget build(BuildContext context) {
    final medicineArg =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ??
        {};
    final String medicineId = medicineArg['id'] ?? '';

    return Consumer<MedicineProvider>(
      builder: (context, provider, child) {
        final medicine = provider.getMedicineById(medicineId);

        if (medicine == null)
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );

        final dateRangeText = _formatDateRange(
          medicine.startDate,
          medicine.endDate,
        );

        return Scaffold(
          backgroundColor: AppColors.gray50,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gray700),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              "Chi tiết thuốc",
              style: TextStyle(
                color: AppColors.gray900,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: AppColors.red500),
                onPressed: () => _confirmDelete(context, medicineId),
              ),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/add-medicine',
                  arguments: medicineId,
                ),
                icon: const Icon(
                  LucideIcons.pencil,
                  size: 20,
                  color: AppColors.blue500,
                ),
                label: const Text(
                  "Sửa",
                  style: TextStyle(color: AppColors.blue500, fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MedicineInfoCard(
                  name: medicine.name,
                  dosage: medicine.dosage,
                  frequency: medicine.frequency.displayName,
                  times: medicine.times.join(', '),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.calendarRange,
                        size: 20,
                        color: AppColors.gray600,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Thời gian dùng:",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateRangeText,
                        style: const TextStyle(
                          color: AppColors.blue500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                FutureBuilder<List<MedicineLogModel>>(
                  future: provider.getHistoryForMedicine(medicineId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text("Chưa có lịch sử dùng thuốc"),
                        ),
                      );
                    }
                    return MedicineHistoryList(history: snapshot.data!);
                  },
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
