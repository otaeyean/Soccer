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
import 'package:shared_preferences/shared_preferences.dart';  // SharedPreferences 추가

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
  String? userName;  // 유저 이름 저장

  final List<Widget> _pages = [
    SchedulePage(),
    RankingPage(),
    InfoPage(),     // 정보 페이지 위치 변경 (3번째)
    CustomizationPage(),
    BoardPage(),     // 게시판 페이지 위치 변경 (5번째)
  ];

  @override
  void initState() {
    super.initState();
    _loadUserName();  // 앱 시작 시 유저 이름 로드
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName');
    });
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KICK OFF', style: TextStyle(fontFamily: "GmarketBold")),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: userName == null
                  ? Text(
                      'KICKOFF',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontFamily: "GmarketBold"),
                    )
                  : Text(
                      ' $userName님,\n 즐거운 축구 되세요!',
                      style: TextStyle(color: Colors.white, fontSize: 23, fontFamily: "GmarketBold"),
                    ),
              decoration: BoxDecoration(
                color: const Color(0xFF37003C),
              ),
            ),
            if (userName == null) ...[
              ListTile(
                title: Text('로그인', style: TextStyle(fontFamily: "GmarketBold")),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
              ListTile(
                title: Text('회원가입', style: TextStyle(fontFamily: "GmarketBold")),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupPage()),
                  );
                },
              ),
            ],
            if (userName != null) ...[
              ListTile(
                title: Text('로그아웃', style: TextStyle(fontFamily: "GmarketBold")),
                onTap: () async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.remove('userName');
                  setState(() {
                    userName = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
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
          BottomNavigationBarItem(icon: Icon(Icons.info), label: '정보'),  // 정보 위치 이동
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '맞춤화'),
          BottomNavigationBarItem(icon: Icon(Icons.forum), label: '게시판'), // 게시판 위치 이동
        ],
      ),
    );
  }
}
