import 'package:flutter/material.dart';

class CustomizationPage extends StatelessWidget {
  final List<Map<String, dynamic>> upcomingMatches = [
    {"date": "11월 10일", "opponent": "웨스트햄", "time": "20:30", "dDay": "D-3"},
    {"date": "11월 15일", "opponent": "에스턴 빌라", "time": "23:00", "dDay": "D-8"},
    {"date": "11월 20일", "opponent": "브렌트퍼드", "time": "23:00", "dDay": "D-13"},
    {"date": "11월 25일", "opponent": "브라이턴", "time": "23:00", "dDay": "D-18"},
  ];

  final List<Map<String, String>> boardPosts = [
    {"title": "다음 경기 예상 라인업?", "author": "팬1", "date": "2024-11-05"},
    {"title": "토트넘 경기 직관 후기", "author": "팬2", "date": "2024-11-04"},
    {"title": "손흥민 요즘 폼 어떠신가요?", "author": "팬3", "date": "2024-11-03"},
    {"title": "웨스트햄전 예상 스코어", "author": "팬4", "date": "2024-11-02"},
    {"title": "토트넘 최근 경기 요약", "author": "팬5", "date": "2024-11-01"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경기 정보 상단부
            Text(
              '토트넘의 가까운 경기',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Column(
              children: upcomingMatches.map((match) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              match["date"],
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '토트넘',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  match["time"],
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  match["opponent"],
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          match["dDay"],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            // 게시판 제목
            Text(
              '토트넘 게시판',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // 게시판 리스트
            Column(
              children: boardPosts.map((post) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(post["title"] ?? ""),
                    subtitle: Text('${post["author"]} • ${post["date"]}'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 게시물 클릭 시 처리할 동작
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
