import 'package:flutter/material.dart';
import 'ranking.dart';
import 'board.dart';
import 'info.dart';
import 'customization.dart';
import 'schedule.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    SchedulePage(),
    RankingPage(),
    BoardPage(),
    InfoPage(),
    CustomizationPage(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter App'),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: '순위'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '게시판'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '정보'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '맞춤화'),
        ],
      ),
    );
  }
}
