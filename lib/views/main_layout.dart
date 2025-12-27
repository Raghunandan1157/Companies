import 'package:flutter/material.dart';
import 'package:corp_pulse/models/data_models.dart';
import 'package:corp_pulse/views/dashboard_tab.dart';
import 'package:corp_pulse/views/regions_tab.dart';
import 'package:corp_pulse/views/profile_tab.dart';
import 'package:corp_pulse/theme/app_theme.dart';
import 'package:corp_pulse/components/glass_background.dart';

class MainLayout extends StatefulWidget {
  final UserSession session;

  const MainLayout({super.key, required this.session});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  late final List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      DashboardTab(session: widget.session),
      RegionsTab(session: widget.session),
      ProfileTab(session: widget.session),
    ];
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive Switch
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Stack(
      children: [
        _tabs[_currentIndex],
        Align(
          alignment: Alignment.bottomCenter,
          child: GlassBackground(
            blur: 20,
            opacity: 0.1,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              backgroundColor: Colors.transparent,
              selectedItemColor: AppTheme.neonCyan,
              unselectedItemColor: Colors.white38,
              elevation: 0,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
                BottomNavigationBarItem(icon: Icon(Icons.table_chart_outlined), label: 'Regions'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          backgroundColor: AppTheme.surface,
          selectedIconTheme: const IconThemeData(color: AppTheme.neonCyan),
          unselectedIconTheme: const IconThemeData(color: Colors.white38),
          selectedLabelTextStyle: const TextStyle(color: AppTheme.neonCyan),
          unselectedLabelTextStyle: const TextStyle(color: Colors.white38),
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), label: Text('Dashboard')),
            NavigationRailDestination(icon: Icon(Icons.table_chart_outlined), label: Text('Regions')),
            NavigationRailDestination(icon: Icon(Icons.person_outline), label: Text('Profile')),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1, color: Colors.white10),
        Expanded(child: _tabs[_currentIndex]),
      ],
    );
  }
}
