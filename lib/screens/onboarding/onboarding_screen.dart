import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/common/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _steps = [
    {
      'icon': LucideIcons.heart,
      'title': 'Theo dõi sức khỏe',
      'description': 'Cân nặng, huyết áp, đường huyết mỗi ngày',
      'color': AppColors.red500,
    },
    {
      'icon': LucideIcons.pill,
      'title': 'Nhắc uống thuốc đúng giờ',
      'description': 'Không bỏ lỡ liều thuốc quan trọng',
      'color': AppColors.blue500,
    },
    {
      'icon': LucideIcons.calendar,
      'title': 'Quản lý sức khỏe dễ dàng',
      'description': 'Theo dõi và phân tích xu hướng sức khỏe',
      'color': AppColors.green500,
    },
  ];

  void _handleNext() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Container(
                    width: 192, // w-48
                    height: 192, // h-48
                    decoration: BoxDecoration(
                      color: step['color'],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      step['icon'],
                      size: 112,
                      color: Colors.white,
                    ), // w-28 h-28
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                step['title'],
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                step['description'],
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_steps.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: index == _currentStep ? 32 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentStep
                          ? AppColors.blue500
                          : AppColors.gray300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: _currentStep == _steps.length - 1
                    ? 'Bắt đầu'
                    : 'Tiếp tục',
                icon: LucideIcons.chevronRight,
                onPressed: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
