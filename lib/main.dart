import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'state/app_state.dart';
import 'widgets/app_bottom_nav.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/planner/planner_hub_screen.dart';
import 'screens/track/track_hub_screen.dart';
import 'screens/tasks/tasks_screen.dart';
import 'screens/shared/quick_add_sheet.dart';

void main() => runApp(const ProductivityApp());

class ProductivityApp extends StatelessWidget {
  const ProductivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: MaterialApp(
        title: 'Productivity',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AppLoader(),
      ),
    );
  }
}

/// Shows a spinner until persisted data has been read from disk, then
/// hands off to the real app shell.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        if (!state.loaded) {
          return const Scaffold(
            backgroundColor: AppColors.bg,
            body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        return const RootShell();
      },
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tab = 0;

  static const _screens = [
    DashboardScreen(),
    PlannerHubScreen(),
    TrackHubScreen(),
    TasksScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tab, children: _screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        onAddTap: () => showQuickAddSheet(context),
      ),
    );
  }
}