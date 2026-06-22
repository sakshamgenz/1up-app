import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/day_planner_provider.dart';
import 'providers/day_review_provider.dart';
import 'providers/weekly_stats_provider.dart';
import 'providers/monthly_stats_provider.dart';
import 'screens/day_planner_screen.dart';
import 'screens/weekly_overview_screen.dart';
import 'screens/monthly_stats_screen.dart';

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
        ChangeNotifierProvider(create: (_) => DayReviewProvider()),
        ChangeNotifierProvider(create: (_) => WeeklyStatsProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyStatsProvider()),
      ],
      child: MaterialApp(
        title: 'JEE Planner',
        theme: AppTheme.theme,
        home: const MainNavigation(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DayPlannerScreen(),
          WeeklyOverviewScreen(),
          MonthlyStatsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Day',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_week),
            label: 'Week',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
