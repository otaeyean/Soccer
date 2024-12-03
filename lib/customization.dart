import 'package:flutter/material.dart';
import 'board_detail_page.dart';

class CustomizationPage extends StatefulWidget {
  @override
  _CustomizationPageState createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  String selectedTeam = "아스날"; // 기본 선택된 팀

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

  final List<String> premierLeagueTeams = [
    "아스날", "아스톤 빌라", "브라이튼", "첼시", "크리스탈 팰리스", "에버튼", "풀햄",
    "리버풀", "맨체스터 시티", "맨유", "뉴캐슬 유나이티드", "노팅엄 포레스트",
    "셰필드 유나이티드", "브렌트포드", "번리", "토트넘", "웨스트햄", "울버햄튼", "사우샘프턴", "레스터 시티"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      title: DropdownButton<String>(
      value: selectedTeam,
      alignment: Alignment.centerLeft, // 왼쪽 정렬
      icon: Icon(Icons.arrow_drop_down, color: Colors.black),
      style: TextStyle(
      color: Colors.black, // 텍스트 색상을 검정으로 설정
      fontSize: 18,
      fontFamily: "GmarketBold",
    ),
      onChanged: (String? newValue) {
      setState(() {
        selectedTeam = newValue!;
      });
    },
    items: premierLeagueTeams.map<DropdownMenuItem<String>>((String team) {
      return DropdownMenuItem<String>(
        value: team,
        child: Text(team),
      );
    }).toList(),
  ),
),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 경기 정보 상단부
            Text(
              '$selectedTeam의 가까운 경기',
              style: TextStyle(
                fontSize: 22,
                fontFamily: "GmarketBold",
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 16),
            Column(
              children: upcomingMatches.map((match) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 카드 테두리 둥글게
                  ),
                  elevation: 5, // 그림자 효과
                  margin: EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white,
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
                              style: TextStyle(fontSize: 16, fontFamily: "GmarketBold"),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  selectedTeam, // 선택된 팀 이름
                                  style: TextStyle(fontSize: 18, fontFamily: "GmarketBold", color: Colors.green),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  match["time"],
                                  style: TextStyle(fontSize: 16, color: Colors.grey[700], fontFamily: "GmarketMedium"),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  match["opponent"],
                                  style: TextStyle(fontSize: 18, fontFamily: "GmarketBold", color: Colors.deepPurple),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          match["dDay"],
                          style: TextStyle(fontSize: 16, color: Colors.redAccent, fontFamily: "GmarketBold"),
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
              '$selectedTeam 게시판',
              style: TextStyle(
                fontSize: 22,
                fontFamily: "GmarketBold",
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 16),
            // 게시판 리스트
            Column(
              children: boardPosts.map((post) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // 카드 테두리 둥글게
                  ),
                  elevation: 5, // 그림자 효과
                  margin: EdgeInsets.symmetric(vertical: 8),
                  color: Colors.white,
                  child: ListTile(
                    title: Text(post["title"] ?? "", style: TextStyle(fontSize: 18, fontFamily: "GmarketBold")),
                    subtitle: Text('${post["author"]} • ${post["date"]}', style: TextStyle(color: Colors.grey[600], fontFamily: "GmarketBold")),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.blueAccent, // 아이콘 색상 변경
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BoardDetailPage(
                            title: post["title"] ?? "",
                            author: post["author"] ?? "",
                            date: post["date"] ?? "",
                          ),
                        ),
                      );
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
