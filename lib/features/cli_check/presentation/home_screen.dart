import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:icefish/core/providers/navigation_provider.dart';
import 'package:icefish/core/utils/responsive.dart';
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

class NavigateToTabIntent extends Intent {
  final int tabIndex;
  const NavigateToTabIntent(this.tabIndex);
}

class NextTabIntent extends Intent {
  const NextTabIntent();
}

class PreviousTabIntent extends Intent {
  const PreviousTabIntent();
}

class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<_NavItem> _navItems = [
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

  static const List<Widget> _screens = [
    HomeContent(),
    CreateProjectContent(),
    EmulatorContent(),
    RunDeployContent(),
    SdkContent(),
    ScreenContent(),
    LayoutContent(),
    SkillsContent(),
    DocsContent(),
    StudioContent(),
  ];

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => const SettingsDialog(),
    );
  }

  Map<ShortcutActivator, Intent> _buildShortcuts() {
    return {
      const SingleActivator(LogicalKeyboardKey.digit1, control: true): const NavigateToTabIntent(0),
      const SingleActivator(LogicalKeyboardKey.digit2, control: true): const NavigateToTabIntent(1),
      const SingleActivator(LogicalKeyboardKey.digit3, control: true): const NavigateToTabIntent(2),
      const SingleActivator(LogicalKeyboardKey.digit4, control: true): const NavigateToTabIntent(3),
      const SingleActivator(LogicalKeyboardKey.digit5, control: true): const NavigateToTabIntent(4),
      const SingleActivator(LogicalKeyboardKey.digit6, control: true): const NavigateToTabIntent(5),
      const SingleActivator(LogicalKeyboardKey.digit7, control: true): const NavigateToTabIntent(6),
      const SingleActivator(LogicalKeyboardKey.digit8, control: true): const NavigateToTabIntent(7),
      const SingleActivator(LogicalKeyboardKey.digit9, control: true): const NavigateToTabIntent(8),
      const SingleActivator(LogicalKeyboardKey.digit0, control: true): const NavigateToTabIntent(9),
      const SingleActivator(LogicalKeyboardKey.tab, control: true): const NextTabIntent(),
      const SingleActivator(LogicalKeyboardKey.tab, control: true, shift: true): const PreviousTabIntent(),
      const SingleActivator(LogicalKeyboardKey.comma, control: true): const OpenSettingsIntent(),
    };
  }

  Map<Type, Action<Intent>> _buildActions() {
    return {
      NavigateToTabIntent: CallbackAction<NavigateToTabIntent>(
        onInvoke: (intent) {
          context.read<NavigationProvider>().setIndex(intent.tabIndex);
          return null;
        },
      ),
      NextTabIntent: CallbackAction<NextTabIntent>(
        onInvoke: (_) {
          context.read<NavigationProvider>().nextTab();
          return null;
        },
      ),
      PreviousTabIntent: CallbackAction<PreviousTabIntent>(
        onInvoke: (_) {
          context.read<NavigationProvider>().previousTab();
          return null;
        },
      ),
      OpenSettingsIntent: CallbackAction<OpenSettingsIntent>(
        onInvoke: (_) {
          _showSettings();
          return null;
        },
      ),
    };
  }

  Widget _buildNavigation(BuildContext context, NavigationProvider nav) {
    final screenSize = Responsive.getScreenSize(context);

    if (screenSize == ScreenSize.compact) {
      return NavigationBar(
        selectedIndex: nav.selectedIndex,
        onDestinationSelected: nav.setIndex,
        destinations: _navItems
            .map((item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ))
            .toList(),
      );
    }

    final bool showLabels = screenSize == ScreenSize.expanded;

    return NavigationRail(
      selectedIndex: nav.selectedIndex,
      groupAlignment: -1.0,
      onDestinationSelected: nav.setIndex,
      labelType: showLabels ? NavigationRailLabelType.all : NavigationRailLabelType.none,
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
              onPressed: _showSettings,
              tooltip: 'Settings (Ctrl+,)',
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, _) {
        final screenSize = Responsive.getScreenSize(context);

        final body = screenSize == ScreenSize.compact
            ? Scaffold(
                body: IndexedStack(
                  index: nav.selectedIndex,
                  children: _screens,
                ),
                bottomNavigationBar: _buildNavigation(context, nav),
              )
            : Scaffold(
                body: SafeArea(
                  child: Row(
                    children: <Widget>[
                      _buildNavigation(context, nav),
                      const VerticalDivider(thickness: 1, width: 1),
                      Expanded(
                        child: IndexedStack(
                          index: nav.selectedIndex,
                          children: _screens,
                        ),
                      ),
                    ],
                  ),
                ),
              );

        return Shortcuts(
          shortcuts: _buildShortcuts(),
          child: Actions(
            actions: _buildActions(),
            child: body,
          ),
        );
      },
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
