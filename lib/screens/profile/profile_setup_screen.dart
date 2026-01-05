import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/auth_provider.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _dobController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _conditionsController = TextEditingController();

  String _gender = 'male';
  DateTime? _selectedDateOfBirth;

  @override
  void dispose() {
    _dobController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _conditionsController.dispose();
    super.dispose();
  }

  // Hàm tính tuổi từ ngày sinh
  int _calculateAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  // Hàm hiển thị lịch chọn ngày
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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

    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _handleSubmit() {
    if (_selectedDateOfBirth == null ||
        _heightController.text.isEmpty ||
        _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    final int calculatedAge = _calculateAge(_selectedDateOfBirth!);

    auth.updateUserProfile(
      age: calculatedAge,
      gender: _gender,
      height: double.tryParse(_heightController.text) ?? 0.0,
      weight: double.tryParse(_weightController.text) ?? 0.0,
      conditions: _conditionsController.text,
      onSuccess: () {
        Navigator.pushReplacementNamed(context, '/main');
      },
      onError: (msg) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.red500),
        );
      },
    );
  }

  Widget _buildGenderOption(String value, String label) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue50 : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.blue500 : AppColors.gray300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.blue500 : AppColors.gray700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.gray700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: AppColors.gray500)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray300, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray300, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.blue500, width: 2),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Hoàn thiện hồ sơ"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Chào mừng bạn mới!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Hãy cập nhật thông tin để chúng tôi hỗ trợ bạn tốt nhất.",
                style: TextStyle(color: AppColors.gray600),
              ),
              const SizedBox(height: 32),

              _buildLabel("Ngày sinh"),
              _buildInput(
                _dobController,
                "Chọn ngày sinh (dd/mm/yyyy)",
                readOnly: true,
                onTap: _selectDate,
                suffixIcon: LucideIcons.calendar,
              ),

              const SizedBox(height: 24),
              _buildLabel("Giới tính"),
              Row(
                children: [
                  _buildGenderOption("male", "Nam"),
                  const SizedBox(width: 16),
                  _buildGenderOption("female", "Nữ"),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Chiều cao (cm)"),
                        _buildInput(
                          _heightController,
                          "Ví dụ: 170",
                          type: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Cân nặng (kg)"),
                        _buildInput(
                          _weightController,
                          "Ví dụ: 65",
                          type: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              _buildLabel("Bệnh nền (Nếu có)"),
              _buildInput(
                _conditionsController,
                "Ví dụ: Tiểu đường, Huyết áp thấp...",
                maxLines: 3,
              ),

              const SizedBox(height: 32),
              CustomButton(
                text: isLoading ? "Đang lưu..." : "Bắt đầu sử dụng",
                onPressed: isLoading ? () {} : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
