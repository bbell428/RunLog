import 'package:flutter/material.dart';
import 'package:runlog/View/Home/home_view.dart';
import 'package:runlog/View/Marathon/marathon_view.dart';
import 'package:runlog/View/Workout/workout_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MainTabView> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeView(),
    WorkoutView(),
    MarathonView(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
    BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: '기록'),
    BottomNavigationBarItem(icon: Icon(Icons.event), label: '마라톤'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onTabTapped,
      ),
    );
  }
}
