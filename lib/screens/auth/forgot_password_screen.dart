import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';
import '../../providers/auth_provider.dart'; // Import AuthProvider

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isSubmitted = false;

  void _handleSubmit() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Vui lòng nhập email")));
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);

    auth.resetPassword(
      _emailController.text,
      () {
        // Thành công: Chuyển UI sang màn hình thông báo đã gửi
        setState(() {
          _isSubmitted = true;
        });
      },
      (errorMsg) {
        // Thất bại: Hiện thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: AppColors.red500),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái loading từ Provider
    final isLoading = Provider.of<AuthProvider>(context).isLoading;

    if (_isSubmitted) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: AppColors.green50,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      LucideIcons.checkCircle,
                      size: 56,
                      color: AppColors.green500,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Đã gửi email!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Vui lòng kiểm tra hộp thư đến (và mục Spam) để đặt lại mật khẩu cho:",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.gray600),
                ),
                const SizedBox(height: 8),
                Text(
                  _emailController.text,
                  style: const TextStyle(
                    color: AppColors.blue500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                CustomButton(
                  text: "Quay lại đăng nhập",
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Quên mật khẩu?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Nhập email của bạn để nhận liên kết đặt lại mật khẩu",
                style: TextStyle(color: AppColors.gray600),
              ),
              const SizedBox(height: 32),
              const Text(
                "Email",
                style: TextStyle(
                  color: AppColors.gray700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress, // Thêm keyboard type
                decoration: InputDecoration(
                  hintText: "email@example.com",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.gray300,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.gray300,
                      width: 2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.blue500,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 24),

              // Nút bấm có trạng thái loading
              CustomButton(
                text: isLoading ? "Đang gửi..." : "Gửi liên kết",
                onPressed: isLoading ? () {} : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
