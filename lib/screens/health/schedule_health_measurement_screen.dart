import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/health_provider.dart';

class ScheduleHealthMeasurementScreen extends StatefulWidget {
  const ScheduleHealthMeasurementScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleHealthMeasurementScreen> createState() =>
      _ScheduleHealthMeasurementScreenState();
}

class _ScheduleHealthMeasurementScreenState
    extends State<ScheduleHealthMeasurementScreen> {
  String? _selectedTypeId;
  final List<TimeOfDay> _reminderTimes = [const TimeOfDay(hour: 8, minute: 0)];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<HealthProvider>(context, listen: false);
      if (provider.metricTypes.isNotEmpty) {
        setState(() {
          _selectedTypeId = provider.metricTypes[0]['id'];
        });
      }
    });
  }

  void _addTime() {
    if (_reminderTimes.length < 5) {
      setState(() => _reminderTimes.add(const TimeOfDay(hour: 12, minute: 0)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tối đa 5 mốc giờ nhắc nhở')),
      );
    }
  }

  void _removeTime(int index) {
    setState(() => _reminderTimes.removeAt(index));
  }

  Future<void> _pickTime(int index) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTimes[index],
      initialEntryMode: TimePickerEntryMode.input, // Chế độ nhập số
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.blue500,
            colorScheme: const ColorScheme.light(primary: AppColors.blue500),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _reminderTimes[index] = picked);
    }
  }

  Future<void> _saveSchedule() async {
    if (_selectedTypeId == null) return;

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<HealthProvider>(context, listen: false);

      // Batch add: Thêm lần lượt các mốc giờ
      for (var time in _reminderTimes) {
        await provider.addSchedule(typeId: _selectedTypeId!, time: time);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu lịch nhắc nhở thành công!'),
            backgroundColor: AppColors.green500,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.red500),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final types = provider.metricTypes;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: const Text("Tạo nhắc nhở mới"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Chỉ số cần đo",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTypeId,
                              isExpanded: true,
                              icon: const Icon(
                                LucideIcons.chevronDown,
                                size: 20,
                              ),
                              items: types.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type['id'],
                                  child: Row(
                                    children: [
                                      Icon(
                                        type['icon'],
                                        size: 18,
                                        color: type['color'],
                                      ),
                                      const SizedBox(width: 12),
                                      Text(type['label']),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedTypeId = val),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionContainer(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Thời gian nhắc",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray700,
                              ),
                            ),
                            InkWell(
                              onTap: _addTime,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  children: const [
                                    Icon(
                                      LucideIcons.plusCircle,
                                      size: 18,
                                      color: AppColors.blue500,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      "Thêm giờ",
                                      style: TextStyle(
                                        color: AppColors.blue500,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._reminderTimes.asMap().entries.map((entry) {
                          int idx = entry.key;
                          TimeOfDay time = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () => _pickTime(idx),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.gray50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.gray200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      LucideIcons.clock,
                                      size: 20,
                                      color: AppColors.gray500,
                                    ),
                                    const SizedBox(width: 12),
                                    Text("Lần ${idx + 1}"),
                                    const Spacer(),
                                    Text(
                                      time.format(context),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.blue600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    if (_reminderTimes.length > 1) ...[
                                      const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(
                                          LucideIcons.x,
                                          size: 20,
                                          color: AppColors.red500,
                                        ),
                                        onPressed: () => _removeTime(idx),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.gray100)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Lưu nhắc nhở",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8),
        ],
      ),
      child: child,
    );
  }
}
