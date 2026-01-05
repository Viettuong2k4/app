import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool medicineReminder = true;
  bool healthReminder = true;
  bool missedMedicine = true;
  bool sound = true;
  bool vibration = true;
  TimeOfDay quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay quietEnd = const TimeOfDay(hour: 7, minute: 0);

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStart ? quietStart : quietEnd,
      initialEntryMode: TimePickerEntryMode.input,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          quietStart = picked;
        } else {
          quietEnd = picked;
        }
      });
    }
  }

  Widget _buildSwitchItem(
    String title,
    String? subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.gray900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.blue500,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gray700),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: AppColors.gray900,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSwitchItem(
                    "Nhắc uống thuốc",
                    "Thông báo khi đến giờ uống thuốc",
                    medicineReminder,
                    (v) => setState(() => medicineReminder = v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchItem(
                    "Nhắc đo chỉ số sức khỏe",
                    "Nhắc nhở theo dõi sức khỏe hàng ngày",
                    healthReminder,
                    (v) => setState(() => healthReminder = v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchItem(
                    "Cảnh báo bỏ lỡ thuốc",
                    "Nhắc khi chưa đánh dấu đã uống thuốc",
                    missedMedicine,
                    (v) => setState(() => missedMedicine = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSwitchItem(
                    "Âm thanh",
                    null,
                    sound,
                    (v) => setState(() => sound = v),
                  ),
                  const Divider(height: 1),
                  _buildSwitchItem(
                    "Rung",
                    null,
                    vibration,
                    (v) => setState(() => vibration = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Giờ yên lặng",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray900,
                    ),
                  ),
                  const Text(
                    "Không nhận thông báo trong khoảng thời gian này",
                    style: TextStyle(fontSize: 14, color: AppColors.gray500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Từ",
                              style: TextStyle(color: AppColors.gray600),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectTime(context, true),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.gray300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(quietStart.format(context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Đến",
                              style: TextStyle(color: AppColors.gray600),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () => _selectTime(context, false),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.gray300),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(quietEnd.format(context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
