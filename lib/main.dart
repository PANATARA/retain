import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/app_data.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'state/planner_state.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Transparent system status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  final plannerState = PlannerState();
  await plannerState.init();

  runApp(
    ChangeNotifierProvider.value(
      value: plannerState,
      child: const EbbinghausPlannerApp(),
    ),
  );
}

class EbbinghausPlannerApp extends StatelessWidget {
  const EbbinghausPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlannerState>();
    final isM3 = state.visualTheme == AppVisualTheme.material3;

    return MaterialApp(
      title: 'Retain',
      debugShowCheckedModeBanner: false,
      theme: isM3 ? AppTheme.material3Light : AppTheme.appleJournalLight,
      darkTheme: isM3 ? AppTheme.material3Dark : AppTheme.appleJournalDark,
      themeMode: state.materialThemeMode,
      home: state.hasSeenOnboarding
          ? const DashboardScreen()
          : const WelcomeScreen(isFromSettings: false),
    );
  }
}
