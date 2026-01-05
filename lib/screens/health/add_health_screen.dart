import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/health_provider.dart';

class AddHealthScreen extends StatefulWidget {
  const AddHealthScreen({Key? key}) : super(key: key);

  @override
  State<AddHealthScreen> createState() => _AddHealthScreenState();
}

class _AddHealthScreenState extends State<AddHealthScreen> {
  String? _selectedTypeId;
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _subValueController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // THÊM: Biến kiểm soát trạng thái submit để tránh duplicate
  bool _isSubmitting = false;

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

  @override
  void dispose() {
    _valueController.dispose();
    _subValueController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveData() async {
    // 1. Chặn nếu đang submit
    if (_isSubmitting) return;

    if (_selectedTypeId == null || _valueController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập giá trị')));
      return;
    }

    final provider = Provider.of<HealthProvider>(context, listen: false);
    final typeInfo = provider.getMetricType(_selectedTypeId!);
    final bool hasSubValue = typeInfo?['hasSubValue'] ?? false;

    if (hasSubValue && _subValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập chỉ số tâm trương')),
      );
      return;
    }

    // 2. Bắt đầu loading
    setState(() => _isSubmitting = true);

    try {
      final DateTime finalDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      double mainVal =
          double.tryParse(_valueController.text.replaceAll(',', '.')) ?? 0;
      double? subVal;
      if (hasSubValue) {
        subVal = double.tryParse(_subValueController.text.replaceAll(',', '.'));
      }

      await provider.addRecord(
        typeId: _selectedTypeId!,
        value: mainVal,
        subValue: subVal,
        date: finalDateTime,
        note: _noteController.text,
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      // 3. Kết thúc loading (nếu chưa thoát màn hình)
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HealthProvider>(context);
    final types = provider.metricTypes;

    if (types.isEmpty) return const SizedBox();

    Map<String, dynamic> currentType = types.first;
    if (_selectedTypeId != null) {
      currentType = types.firstWhere(
        (t) => t['id'] == _selectedTypeId,
        orElse: () => types.first,
      );
    }

    final bool isBloodPressure = currentType['hasSubValue'] == true;
    final String unit = currentType['unit'];
    final String mainLabel = isBloodPressure
        ? (currentType['mainLabel'] ?? "Tâm thu")
        : "Kết quả đo";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Thêm chỉ số mới"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel("Loại chỉ số"),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gray50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gray200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedTypeId,
                          isExpanded: true,
                          icon: const Icon(LucideIcons.chevronDown, size: 20),
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
                          onChanged: (val) {
                            setState(() {
                              _selectedTypeId = val;
                              _valueController.clear();
                              _subValueController.clear();
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (isBloodPressure) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildNumberInput(
                              controller: _valueController,
                              label: mainLabel,
                              unit: unit,
                              hint: "120",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildNumberInput(
                              controller: _subValueController,
                              label: currentType['subLabel'] ?? "Tâm trương",
                              unit: unit,
                              hint: "80",
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildNumberInput(
                        controller: _valueController,
                        label: mainLabel,
                        unit: unit,
                        hint: "0.0",
                      ),
                    ],

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimePick(
                            label: "Ngày đo",
                            text: DateFormat(
                              'dd/MM/yyyy',
                            ).format(_selectedDate),
                            icon: LucideIcons.calendar,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateTimePick(
                            label: "Giờ đo",
                            text: _selectedTime.format(context),
                            icon: LucideIcons.clock,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildLabel("Ghi chú (Tùy chọn)"),
                    TextFormField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Ví dụ: Sau khi ăn...",
                        filled: true,
                        fillColor: AppColors.gray50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.gray200,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.gray200,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting
                      ? null
                      : _saveData, // Disable khi đang lưu
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Lưu chỉ số",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Các widget helper giữ nguyên...
  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required String unit,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit,
            filled: true,
            fillColor: AppColors.gray50,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePick({
    required String label,
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.gray50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray200),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.gray500),
                const SizedBox(width: 8),
                Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.gray700,
        ),
      ),
    );
  }
}
