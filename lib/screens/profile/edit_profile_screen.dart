import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;

  String _gender = 'male';
  DateTime? _dob;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userInfo;

    _nameController = TextEditingController(
      text: user['fullName'] ?? user['name'] ?? '',
    );
    _phoneController = TextEditingController(text: user['phone'] ?? '');
    _addressController = TextEditingController(text: user['address'] ?? '');
    _heightController = TextEditingController(
      text: user['height']?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: user['weight']?.toString() ?? '',
    );

    _gender = user['gender'] ?? 'male';

    if (user['dob'] != null) {
      if (user['dob'] is Timestamp) {
        _dob = (user['dob'] as Timestamp).toDate();
      } else if (user['dob'] is String) {
        _dob = DateTime.tryParse(user['dob']);
      } else if (user['dob'] is DateTime) {
        _dob = user['dob'];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
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
    if (picked != null) setState(() => _dob = picked);
  }

  void _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      double? h = double.tryParse(_heightController.text.replaceAll(',', '.'));
      double? w = double.tryParse(_weightController.text.replaceAll(',', '.'));

      await Provider.of<AuthProvider>(context, listen: false).updateUserInfo({
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'gender': _gender,
        'dob': _dob,
        'height': h,
        'weight': w,
      });

      final healthProvider = Provider.of<HealthProvider>(
        context,
        listen: false,
      );
      final now = DateTime.now();

      if (h != null && h > 0) {
        await healthProvider.addRecord(
          typeId: 'height',
          value: h,
          date: now,
          note: 'Cập nhật từ hồ sơ',
        );
      }

      if (w != null && w > 0) {
        await healthProvider.addRecord(
          typeId: 'weight',
          value: w,
          date: now,
          note: 'Cập nhật từ hồ sơ',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thành công!'),
            backgroundColor: AppColors.green500,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: AppColors.red500,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gray900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.blue50,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blue100, width: 2),
                    ),
                    child: const Icon(
                      LucideIcons.user,
                      size: 48,
                      color: AppColors.blue500,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.blue500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.camera,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildInputGroup(
              "Họ và tên",
              _nameController,
              icon: LucideIcons.user,
            ),
            const SizedBox(height: 16),

            _buildInputGroup(
              "Số điện thoại",
              _phoneController,
              icon: LucideIcons.phone,
              inputType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            _buildInputGroup(
              "Địa chỉ",
              _addressController,
              icon: LucideIcons.mapPin,
            ),
            const SizedBox(height: 16),

            const Text(
              "Ngày sinh",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.calendar,
                      size: 20,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _dob != null
                          ? DateFormat('dd/MM/yyyy').format(_dob!)
                          : "Chọn ngày sinh",
                      style: TextStyle(
                        fontSize: 16,
                        color: _dob != null
                            ? AppColors.gray900
                            : AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              "Giới tính",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildGenderOption("Nam", "male"),
                const SizedBox(width: 16),
                _buildGenderOption("Nữ", "female"),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildInputGroup(
                    "Chiều cao (cm)",
                    _heightController,
                    inputType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInputGroup(
                    "Cân nặng (kg)",
                    _weightController,
                    inputType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                        "Lưu thay đổi",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInputGroup(
    String label,
    TextEditingController controller, {
    IconData? icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          style: const TextStyle(fontSize: 16, color: AppColors.gray900),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, size: 20, color: AppColors.gray400)
                : null,
            filled: true,
            fillColor: AppColors.gray50,
            hintText: "Nhập $label",
            hintStyle: const TextStyle(color: AppColors.gray400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.blue500,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption(String label, String value) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue50 : AppColors.gray50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.blue500 : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.blue500 : AppColors.gray600,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
