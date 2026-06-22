import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/day_planner_provider.dart';
import 'screens/day_planner_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DayPlannerProvider()),
      ],
      child: MaterialApp(
        title: 'JEE Planner',
        theme: AppTheme.theme,
        home: const DayPlannerScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
