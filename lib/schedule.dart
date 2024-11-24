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
                child: Text('←', style: TextStyle(fontSize: 30)),
              ),
              SizedBox(width: 13),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  DateFormat('MM.dd(E)', 'ko_KR').format(currentDate),
                  style: TextStyle(fontSize: 20, fontFamily: 'KBO_Medium'),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () => changeDate(1),
                child: Text('→', style: TextStyle(fontSize: 30)),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: matches.isEmpty
                ? Center(child: Text("오늘은 경기가 없습니다"))
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatingPage()),
        );
      },
      child: Container(
        height: 140,
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Stack(
            children: [
              Positioned(
                left: 45,
                top: 10,
                child: Text(
                  match['team1'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                right: 45,
                top: 10,
                child: Text(
                  match['team2'] ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                left: 65,
                top: 30,
                child: Text(
                  match['team1Score'] ?? '',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                right: 65,
                top: 30,
                child: Text(
                  match['team2Score'] ?? '',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Text(
                  match['place'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Text(
                  match['time'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Positioned(
                top: 52,
                left: 0,
                right: 0,
                child: Text(
                  match['league'] ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}