import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:songkhoe/providers/health_provider.dart';
import 'package:songkhoe/providers/medicine_provider.dart';
import '../../providers/navigation_provider.dart';
import '../../widgets/components/bottom_nav_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../health/health_screen.dart';
import '../medicine/medicine_screen.dart';
import '../profile/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HealthProvider>(context, listen: false).fetchRecords();
      Provider.of<MedicineProvider>(context, listen: false).fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = Provider.of<NavigationProvider>(context).currentIndex;

    final List<Widget> screens = [
      const DashboardScreen(),
      const HealthScreen(),
      const MedicineScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
