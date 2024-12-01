import 'package:flutter/material.dart';
import 'ranking.dart';
import 'board.dart';
import 'info.dart';
import 'customization.dart';
import 'schedule.dart';
import 'chating.dart'; 
import 'login_page.dart'; 
import 'signup_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('ko_KR', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.blueGrey,
          selectedItemColor: Color(0xFF37003C),
          unselectedItemColor: Colors.grey,
        ),
      ),
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
        title: Text('KICK OFF', style: TextStyle(fontFamily: "GmarketBold"),),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'KICKOFF',
                style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: "GmarketBold"),
              ),
              decoration: BoxDecoration(
                color: const  Color(0xFF37003C),
              ),
            ),
            ListTile(
              title: Text('로그인', style: TextStyle(fontFamily: "GmarketBold"),),
              onTap: () {
                Navigator.pop(context); // 사이드바 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            ListTile(
              title: Text('회원가입', style: TextStyle(fontFamily: "GmarketBold"),),
              onTap: () {
                Navigator.pop(context); // 사이드바 닫기
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedLabelStyle: TextStyle(fontFamily: "GmarketMedium"),
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
