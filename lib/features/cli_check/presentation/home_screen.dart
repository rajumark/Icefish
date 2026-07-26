import 'package:flutter/material.dart';
import 'package:icefish/features/cli_check/presentation/settings_dialog.dart';
import 'package:icefish/features/home/presentation/home_content.dart';
import 'package:icefish/features/emulator/presentation/emulator_content.dart';
import 'package:icefish/features/sdk/presentation/sdk_content.dart';
import 'package:icefish/features/screen/presentation/screen_content.dart';
import 'package:icefish/features/layout/presentation/layout_content.dart';
import 'package:icefish/features/skills/presentation/skills_content.dart';
import 'package:icefish/features/create_project/presentation/create_project_content.dart';
import 'package:icefish/features/run_deploy/presentation/run_deploy_content.dart';
import 'package:icefish/features/docs/presentation/docs_content.dart';
import 'package:icefish/features/studio/presentation/studio_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.create_new_folder_outlined, selectedIcon: Icons.create_new_folder, label: 'Create'),
    _NavItem(icon: Icons.phone_android, selectedIcon: Icons.phone_android, label: 'Emulator'),
    _NavItem(icon: Icons.play_circle_outlined, selectedIcon: Icons.play_circle, label: 'Run'),
    _NavItem(icon: Icons.inventory_2_outlined, selectedIcon: Icons.inventory_2, label: 'SDK'),
    _NavItem(icon: Icons.photo_camera_outlined, selectedIcon: Icons.photo_camera, label: 'Screen'),
    _NavItem(icon: Icons.account_tree_outlined, selectedIcon: Icons.account_tree, label: 'Layout'),
    _NavItem(icon: Icons.extension_outlined, selectedIcon: Icons.extension, label: 'Skills'),
    _NavItem(icon: Icons.menu_book_outlined, selectedIcon: Icons.menu_book, label: 'Docs'),
    _NavItem(icon: Icons.code_outlined, selectedIcon: Icons.code, label: 'Studio'),
  ];

  late final List<Widget> _screens = [
    const HomeContent(),
    const CreateProjectContent(),
    const EmulatorContent(),
    const RunDeployContent(),
    const SdkContent(),
    const ScreenContent(),
    const LayoutContent(),
    const SkillsContent(),
    const DocsContent(),
    const StudioContent(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: <Widget>[
            NavigationRail(
              selectedIndex: _selectedIndex,
              groupAlignment: -1.0,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(Icons.android, size: 32, color: Colors.teal),
              ),
              destinations: _navItems
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ))
                  .toList(),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const SettingsDialog(),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
