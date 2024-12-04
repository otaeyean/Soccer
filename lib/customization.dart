import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CustomizationPage extends StatefulWidget {
  @override
  _CustomizationPageState createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  String selectedTeam = "토트넘"; // 기본 선택된 팀
  List<Map<String, dynamic>> upcomingMatches = []; // 파이어베이스에서 가져온 경기 데이터

  final List<String> premierLeagueTeams = [
    "브렌트포드", "레스터 시티 FC", "크리스탈 팰리스", "뉴캐슬", "노팅엄", "입스위치 타운",
    "울버햄튼", "본머스", "웨스트햄", "아스널", "첼시", "애스턴 빌라", "맨유",
    "에버턴", "토트넘", "풀럼", "리버풀", "맨시티"
  ];

  @override
  void initState() {
    super.initState();
    fetchUpcomingMatches(); // 파이어베이스에서 데이터를 가져옴
  }

  // D-DAY 계산 수정
  String calculateDDay(DateTime matchDate) {
    final now = DateTime.now();
    final difference = matchDate.difference(now).inDays;

    // D-DAY가 아닌 경우 표시
    if (difference == 0) return "D-Day";
    if (difference < 0) return "경기 종료"; // 경기 종료 표시
    return "D-${difference}";
  }

  void fetchUpcomingMatches() async {
    DateTime now = DateTime.now(); // 오늘 날짜
    DateTime todayAtMidnight = DateTime(now.year, now.month, now.day); // 오늘 자정

    // 첫 번째 쿼리: team1 기준
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection('schedules')
        .where('team1', isEqualTo: selectedTeam)
        .get();

    // 두 번째 쿼리: team2 기준
    QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
        .collection('schedules')
        .where('team2', isEqualTo: selectedTeam)
        .get();

    // 두 쿼리 결과 합치기
    List<QueryDocumentSnapshot> allMatches = [];
    allMatches.addAll(querySnapshot1.docs);
    allMatches.addAll(querySnapshot2.docs);

    // 날짜 기준으로 정렬
    allMatches.sort((a, b) {
      DateTime? dateA = parseDate(a['date']);
      DateTime? dateB = parseDate(b['date']);
      // 날짜 비교 (null이 있을 경우 0을 반환해서 비교할 수 있도록 함)
      if (dateA == null || dateB == null) return 0;
      return dateA.compareTo(dateB);
    });

    // 오늘 날짜 이후의 경기만 필터링
    setState(() {
      upcomingMatches = allMatches.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // 날짜 포맷 개선: 숫자 기반 날짜만 파싱하도록 수정
        DateTime? matchDate = parseDate(data['date']);
        if (matchDate == null || matchDate.isBefore(todayAtMidnight)) {
          return null; // 날짜가 오늘 이전이면 건너뛰기
        }

        String dDay = calculateDDay(matchDate);

        // 경기 데이터 로그로 출력
        print("경기 데이터: ");
        print("날짜: ${DateFormat('MM월 dd일').format(matchDate)}");
        print("상대팀: ${data['team2']}");
        print("시간: ${data['time']}");
        print("D-DAY: $dDay");

        return {
          "date": DateFormat('MM월 dd일').format(matchDate),
          "opponent": data['team2'] ?? "상대 팀 없음",
          "time": data['time'] ?? "시간 미정",
          "dDay": dDay,
        };
      })
          .where((match) => match != null) // null 데이터 제거
          .cast<Map<String, dynamic>>() // non-nullable로 캐스팅
          .take(5) // 최대 5개의 경기만 표시
          .toList(); // 유효한 데이터만 가져오기
    });
  }


  DateTime? parseDate(String dateString) {
    try {
      // 예시: "12.08 수" -> DateTime(2024, 12, 8)
      final match = RegExp(r'(\d{2})\.(\d{2})\s+[가-힣]+').firstMatch(dateString);
      if (match != null) {
        int month = int.parse(match.group(1)!);  // 월 추출
        int day = int.parse(match.group(2)!);    // 일 추출
        final currentYear = DateTime.now().year; // 현재 연도 사용
        return DateTime(currentYear, month, day); // DateTime 객체로 변환
      }
      return null; // 잘못된 포맷이면 null 반환
    } catch (e) {
      print("날짜 변환 오류: $e");
      return null;
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DropdownButton<String>(
          value: selectedTeam,
          alignment: Alignment.centerLeft,
          icon: Icon(Icons.arrow_drop_down, color: Colors.black),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontFamily: "GmarketBold",
          ),
          onChanged: (String? newValue) {
            setState(() {
              selectedTeam = newValue!;
              fetchUpcomingMatches(); // 선택 팀 변경 시 데이터 새로고침
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
            Text(
              '$selectedTeam의 가까운 경기',
              style: TextStyle(
                fontSize: 22,
                fontFamily: "GmarketBold",
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 16),
            upcomingMatches.isEmpty
                ? Center(
              child: Text(
                "경기가 없습니다.",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "GmarketBold",
                  color: Colors.red,
                ),
              ),
            )
                : Column(
              children: upcomingMatches.map((match) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5,
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
                              match["date"]!,
                              style: TextStyle(
                                  fontSize: 16, fontFamily: "GmarketBold"),
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  selectedTeam,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: "GmarketBold",
                                      color: Colors.green),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  match["time"]!,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                      fontFamily: "GmarketMedium"),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  match["opponent"]!,
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontFamily: "GmarketBold",
                                      color: Colors.deepPurple),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          match["dDay"]!,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.redAccent,
                              fontFamily: "GmarketBold"),
                        ),
                      ],
                    ),
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
