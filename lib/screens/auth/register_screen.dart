// File: lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gray700),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Quay lại",
          style: TextStyle(color: AppColors.gray700, fontSize: 16),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Tạo tài khoản",
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.blue900,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Đăng ký để bắt đầu theo dõi sức khỏe",
                style: TextStyle(fontSize: 16, color: AppColors.gray600),
              ),
              const SizedBox(height: 32),

              _buildTextField("Họ và tên", "Nguyễn Văn A", _nameController),
              const SizedBox(height: 24),
              _buildTextField("Email", "email@example.com", _emailController),
              const SizedBox(height: 24),

              _buildPasswordField(
                "Mật khẩu",
                _passwordController,
                _showPassword,
                () {
                  setState(() => _showPassword = !_showPassword);
                },
              ),
              const SizedBox(height: 24),

              _buildPasswordField(
                "Xác nhận mật khẩu",
                _confirmPasswordController,
                _showConfirmPassword,
                () {
                  setState(() => _showConfirmPassword = !_showConfirmPassword);
                },
              ),

              const SizedBox(height: 32),

              // --- Button Register ---
              Consumer<AuthProvider>(
                builder: (context, auth, _) => CustomButton(
                  text: auth.isLoading ? "Đang tạo..." : "Tạo tài khoản",
                  onPressed: () {
                    // Validate
                    if (_nameController.text.isEmpty ||
                        _emailController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vui lòng nhập tên và email"),
                        ),
                      );
                      return;
                    }
                    if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Mật khẩu không khớp")),
                      );
                      return;
                    }

                    // Gọi API Register
                    auth.register(
                      _nameController.text,
                      _emailController.text,
                      _passwordController.text,
                      () {
                        // Thành công: Chuyển đến màn hình chính (hoặc setup profile)
                        // Xóa hết stack cũ để user không back về login được
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/profile-setup', // Chuyển hướng sang Setup
                          (route) => false,
                        );
                      },
                      (errorMsg) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMsg),
                            backgroundColor: AppColors.red500,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.gray700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
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
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isVisible,
    VoidCallback onToggle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.gray700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: "••••••••",
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(16),
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
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? LucideIcons.eyeOff : LucideIcons.eye,
                color: AppColors.gray500,
              ),
              onPressed: onToggle,
            ),
          ),
        ),
      ],
    );
  }
}
