import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:songkhoe/screens/medicine/medicine_date_selector.dart';
import 'package:songkhoe/screens/medicine/medicine_time_selector.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/medicine_provider.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({Key? key}) : super(key: key);

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();

  List<TimeOfDay> _times = [const TimeOfDay(hour: 7, minute: 0)];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _reminderEnabled = true;

  String? _medicineId;
  bool _isDataLoaded = false;

  bool get isEdit => _medicineId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDataLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _medicineId = args;
        _loadMedicineData();
      }
      _isDataLoaded = true;
    }
  }

  void _loadMedicineData() {
    if (_medicineId == null) return;
    final provider = Provider.of<MedicineProvider>(context, listen: false);
    final medicine = provider.getMedicineById(_medicineId!);

    if (medicine != null) {
      setState(() {
        _nameController.text = medicine.name;
        _dosageController.text = medicine.dosage;
        _reminderEnabled = medicine.note.contains('Đã bật nhắc nhở');

        if (medicine.times.isNotEmpty) {
          _times = medicine.times.map((t) {
            final parts = t.split(':');
            return TimeOfDay(
              hour: int.parse(parts[0]),
              minute: int.parse(parts[1]),
            );
          }).toList();
        }
        _startDate = medicine.startDate;
        _endDate = medicine.endDate;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_nameController.text.isEmpty || _dosageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên và liều lượng')),
      );
      return;
    }
    if (_times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng thêm ít nhất 1 giờ uống')),
      );
      return;
    }

    List<String> timeList = _times
        .map(
          (t) =>
              "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}",
        )
        .toList();

    final provider = Provider.of<MedicineProvider>(context, listen: false);

    if (isEdit) {
      provider.updateMedicine(
        id: _medicineId!,
        name: _nameController.text,
        dosage: _dosageController.text,
        times: timeList,
        frequency: "${_times.length} lần/ngày",
        note: _reminderEnabled ? "Đã bật nhắc nhở" : "",
        startDate: _startDate,
        endDate: _endDate,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật thông tin thuốc')),
      );
    } else {
      provider.addMedicine(
        name: _nameController.text,
        dosage: _dosageController.text,
        times: timeList,
        frequency: "${_times.length} lần/ngày",
        note: _reminderEnabled ? "Đã bật nhắc nhở" : "",
        startDate: _startDate,
        endDate: _endDate,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã thêm thuốc mới')));
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        title: Text(isEdit ? 'Chỉnh sửa thuốc' : 'Thêm thuốc mới'),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Tên thuốc"),
            _buildTextField(_nameController, "Ví dụ: Metformin 500mg"),
            const SizedBox(height: 24),

            _buildLabel("Liều lượng"),
            _buildTextField(_dosageController, "Ví dụ: 1 viên"),
            const SizedBox(height: 24),

            MedicineTimeSelector(
              times: _times,
              onAdd: () {
                if (_times.length < 5)
                  setState(
                    () => _times.add(const TimeOfDay(hour: 8, minute: 0)),
                  );
              },
              onRemove: (index) => setState(() => _times.removeAt(index)),
              onTimeChanged: (index, newTime) =>
                  setState(() => _times[index] = newTime),
            ),
            const SizedBox(height: 24),

            MedicineDateSelector(
              startDate: _startDate,
              endDate: _endDate,
              onStartDateChanged: (val) => setState(() => _startDate = val),
              onEndDateChanged: (val) => setState(() => _endDate = val),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Bật nhắc uống thuốc",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Nhận thông báo khi đến giờ",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _reminderEnabled,
                    activeColor: AppColors.blue500,
                    onChanged: (val) => setState(() => _reminderEnabled = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEdit ? 'Lưu thay đổi' : 'Thêm thuốc',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helpers
  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray300),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: AppColors.gray700,
      ),
    ),
  );
}
