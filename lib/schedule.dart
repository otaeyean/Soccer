import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'chating.dart';

class SchedulePage extends StatefulWidget {
  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime currentDate = DateTime.now();
  List<Map<String, dynamic>> matches = [];

  @override
  void initState() {
    super.initState();
    fetchMatches();
  }

  void fetchMatches() async {
    String formattedDate = DateFormat('MM.dd E', 'ko_KR').format(currentDate);
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('date', isEqualTo: formattedDate)
        .get();

    setState(() {
      matches = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void changeDate(int days) {
    setState(() {
      currentDate = currentDate.add(Duration(days: days));
      fetchMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => changeDate(-1),
                child: Text('←', style: TextStyle(fontSize: 30, fontFamily: "GmarketBold")),
              ),
              SizedBox(width: 13),
              Padding(
                padding: EdgeInsets.only(top: 1),
                child: Text(
                  DateFormat('MM.dd(E)', 'ko_KR').format(currentDate),
                  style: TextStyle(fontSize: 20, fontFamily: "GmarketBold"),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => changeDate(1),
                child: Text('→', style: TextStyle(fontSize: 30, fontFamily: "GmarketBold")),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: matches.isEmpty
                ? Center(child: Text("오늘은 경기가 없습니다", style: TextStyle(fontSize: 17, fontFamily: "GmarketBold"),))
                : ListView.builder(
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return GameListItem(match: matches[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class GameListItem extends StatelessWidget {
  final Map<String, dynamic> match;

  GameListItem({required this.match});

  String getImagePath(String teamName) {
    // 팀 이름과 매칭된 이미지 경로 반환
    if (teamName.isNotEmpty) {
      return 'assets/images/$teamName.png';
    } else {
      return 'assets/images/default.png'; // 기본 이미지 경로
    }
  }

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatingPage(
            team1: match['team1'] ?? 'Team1',
            team2: match['team2'] ?? 'Team2',
            round: match['round'] ?? 'Unknown Round',
          ),
        ),
      );
    },
    child: Container(
      height: 145,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Stack(
          children: [
            // 팀 1 이미지
            Positioned(
              left: 20,
              top: 70,
              child: Image.asset(
                getImagePath(match['team1'] ?? 'default'),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            // 팀 1 이름
            Positioned(
              left: 15,
              top: 35,
              child: Text(
                match['team1'] ?? '',
                style: TextStyle(fontSize: 18, fontFamily: "GmarketBold"),
              ),
            ),
            // 팀 2 이미지
            Positioned(
              right: 20,
              top: 70,
              child: Image.asset(
                getImagePath(match['team2'] ?? 'default'),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            // 팀 2 이름
            Positioned(
              right: 15,
              top: 35, // 이미지 위쪽에 위치
              child: Text(
                match['team2'] ?? '',
                style: TextStyle(fontSize: 18, fontFamily: "GmarketBold"),
              ),
            ),
            // 점수 표시
            Positioned(
              left: 115,
              top: 80,
              child: Text(
                match['team1Score'] ?? '',
                style: TextStyle(fontSize: 30, fontFamily: "GmarketBold"),
              ),
            ),
            Positioned(
              right: 115,
              top: 80,
              child: Text(
                match['team2Score'] ?? '',
                style: TextStyle(fontSize: 30, fontFamily: "GmarketBold"),
              ),
            ),
            // 경기장 정보
            Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Text(
                match['place'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontFamily: "GmarketMedium"),
              ),
            ),
            // 경기 시간
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Text(
                match['time'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, fontFamily: "GmarketMedium"),
              ),
            ),
            // 리그 정보
            Positioned(
              top: 52,
              left: 0,
              right: 0,
              child: Text(
                match['league'] ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.blue, fontFamily: "GmarketMedium"),
              ),
            ),
            // VS
           Positioned(
              top: 85,
              left: 0,
              right: 0,
              child: Text(
                'VS',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontFamily: "GmarketBold"),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}