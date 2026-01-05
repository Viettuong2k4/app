import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:songkhoe/screens/profile/edit_profile_screen.dart';
import 'package:songkhoe/screens/profile/notification_settings_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/health_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final userInfo = auth.userInfo;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white,
              width: double.infinity,
              child: const Text(
                "Cá nhân",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray900,
                ),
              ),
            ),
            const Divider(height: 1, color: AppColors.gray200),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Card
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.blueGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.user,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    auth.userName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    auth.userEmail,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.blue100,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              LucideIcons.chevronRight,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    // Stats
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
                            "Thông tin sức khỏe",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray900,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 2.5,
                            children: [
                              _buildStat("Tuổi", auth.userAge),
                              _buildStat(
                                "Giới tính",
                                userInfo['gender'] == 'male'
                                    ? "Nam"
                                    : (userInfo['gender'] == 'female'
                                          ? "Nữ"
                                          : "--"),
                              ),
                              _buildStat(
                                "Chiều cao",
                                "${userInfo['height'] ?? '--'} cm",
                              ),
                              _buildStat(
                                "Cân nặng",
                                "${userInfo['weight'] ?? '--'} kg",
                              ),
                            ],
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
                          _buildMenuItem(
                            LucideIcons.settings,
                            "Cài đặt đơn vị đo",
                            trailing: const Icon(
                              LucideIcons.chevronRight,
                              size: 20,
                              color: AppColors.gray400,
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.gray100),
                          _buildMenuItem(
                            LucideIcons.globe,
                            "Ngôn ngữ",
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  "Tiếng Việt",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.gray500,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(
                                  LucideIcons.chevronRight,
                                  size: 20,
                                  color: AppColors.gray400,
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: AppColors.gray100),
                          _buildMenuItem(
                            LucideIcons.bell,
                            "Thông báo",
                            trailing: const Icon(
                              LucideIcons.chevronRight,
                              size: 20,
                              color: AppColors.gray400,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationSettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        Provider.of<HealthProvider>(
                          context,
                          listen: false,
                        ).clearData();

                        // 2. Logout Firebase
                        await auth.logout();

                        // 3. Navigate về Login
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              LucideIcons.logOut,
                              color: AppColors.red500,
                              size: 20,
                            ),
                            SizedBox(width: 16),
                            Text(
                              "Đăng xuất",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.red500,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Phiên bản 1.0.0",
                      style: TextStyle(color: AppColors.gray500, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.gray500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.gray900,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: AppColors.gray600),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 16, color: AppColors.gray900),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
