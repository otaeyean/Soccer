import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_team_post.dart';
import 'post_detail_team.dart';
import 'news_detail_page.dart';

class CustomizationPage extends StatefulWidget {
  @override
  _CustomizationPageState createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  String selectedTeam = "토트넘"; // 기본 선택된 팀
  List<Map<String, dynamic>> upcomingMatches = []; // 파이어베이스에서 가져온 경기 데이터
  List<Map<String, dynamic>> boardPosts = []; // 게시판 데이터 (Firebase에서 가져오는 예시)
  List<Map<String, dynamic>> newsItems = []; // 뉴스 데이터

  final List<String> premierLeagueTeams = [
    "브렌트포드", "레스터 시티 FC", "크리스탈 팰리스", "뉴캐슬", "노팅엄", "입스위치 타운",
    "울버햄튼", "본머스", "웨스트햄", "아스널", "첼시", "애스턴 빌라", "맨유",
    "에버턴", "토트넘", "풀럼", "리버풀", "맨시티"
  ];

  @override
  void initState() {
    super.initState();
    fetchUpcomingMatches(); // 파이어베이스에서 데이터를 가져옴
    fetchBoardPosts(); // 게시판 데이터 가져오기
    fetchNews(); // 뉴스 데이터 가져오기
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
    DateTime todayAtMidnight = DateTime(now.year, now.month, now.day+1); // 오늘 자정

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

        // team1과 team2가 같은 경우를 피하려면, 상대 팀을 기준으로 'team2' 또는 'team1'로 설정해야 한다.
        String opponent = (selectedTeam == data['team1']) ? data['team2'] : data['team1'];

        return {
          "date": DateFormat('MM월 dd일').format(matchDate),
          "opponent": opponent,
          "time": data['time'] ?? "시간 미정",
          "dDay": dDay,
        };
      })
          .where((match) => match != null)
          .cast<Map<String, dynamic>>()
          .take(5)
          .toList();
    });
  }

  void fetchBoardPosts() async {
    // 'board_posts' 컬렉션에서 선택된 팀에 맞는 게시판 데이터 가져오기
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('board_posts')
        .where('team', isEqualTo: selectedTeam) // 팀에 해당하는 게시글만 가져옴
        .limit(5)
        .get();

    setState(() {
      boardPosts = querySnapshot.docs.map((doc) {
        return {
          "title": doc['title'] ?? "",
          "author": doc['username'] ?? "",
          "date": doc['timestamp'] != null
              ? formatTimestamp(doc['timestamp']) // 타임스탬프 형식으로 변환
              : "",
          "commentCount": doc['commentCount'] ?? 0, // 댓글 수
          "content": doc['content'] ?? "", // 내용
          "team": doc['team'] ?? "", // 팀명
          "userId": doc['userId'] ?? "", // 사용자 ID
          "postId": doc.id, // Firestore 문서 ID를 postId로 사용
        };
      }).toList();
    });
  }

  void fetchNews() async {
    // 'news' 컬렉션에서 선택된 팀에 맞는 뉴스 데이터 가져오기
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('news')
        .where('team', isEqualTo: selectedTeam) // 팀에 해당하는 뉴스만 가져옴
        .limit(5)
        .get();

    setState(() {
      newsItems = querySnapshot.docs.map((doc) {
        return {
          "title": doc['title'] ?? "",
          "content": doc['content'] ?? "",
          "image": doc['image'] ?? "",
          "time": doc['time'] ?? "",
          "newsId": doc.id,
        };
      }).toList();
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return "${dateTime.year}년 ${dateTime.month}월 ${dateTime.day}일 ${dateTime.hour}시 ${dateTime.minute}분 ${dateTime.second}초";
  }

  DateTime? parseDate(String dateString) {
    try {
      final match = RegExp(r'(\d{2})\.(\d{2})\s+[가-힣]+').firstMatch(dateString);
      if (match != null) {
        int month = int.parse(match.group(1)!);
        int day = int.parse(match.group(2)!);
        final currentYear = DateTime.now().year;
        return DateTime(currentYear, month, day);
      }
      return null;
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
              fetchBoardPosts(); // 팀에 맞는 게시판 데이터 가져오기
              fetchNews(); // 뉴스 데이터 새로 고침
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
            // 팀 경기 정보
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

            // 게시판 리스트
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$selectedTeam 게시판',
                  style: TextStyle(
                    fontSize: 22,
                    fontFamily: "GmarketBold",
                    color: Colors.blueGrey,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add, color: Colors.blue),
                  onPressed: () async {
                    // 게시글 작성 페이지로 이동 (selectedTeam 전달)
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostPage(selectedTeam: selectedTeam),
                      ),
                    );
                    // 게시글 작성 후 돌아왔을 때, 게시판 데이터를 새로 고침
                    fetchBoardPosts();  // 새로운 게시글을 반영하기 위해 호출
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            boardPosts.isEmpty
                ? Center(
              child: Text(
                "게시물이 없습니다.",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "GmarketBold",
                  color: Colors.red,
                ),
              ),
            )
                : Column(
              children: boardPosts.map((post) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(  // 클릭을 감지하기 위한 GestureDetector
                    onTap: () {
                      // 클릭 시 해당 게시글의 상세 페이지로 이동
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(
                            postId: post["postId"] ?? 'defaultId',
                            boardType: selectedTeam,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5,
                        margin: EdgeInsets.all(0),
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post["title"]!,
                                style: TextStyle(fontSize: 16, fontFamily: "GmarketBold"),
                              ),
                              SizedBox(height: 8),
                              Text(
                                post["author"]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: "GmarketMedium",
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                post["date"]!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontFamily: "GmarketMedium",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            // 뉴스 리스트
            SizedBox(height: 32),
            Text(
              '$selectedTeam 뉴스',
              style: TextStyle(
                fontSize: 22,
                fontFamily: "GmarketBold",
                color: Colors.blueGrey,
              ),
            ),
            SizedBox(height: 16),
            newsItems.isEmpty
                ? Center(
              child: Text(
                "뉴스가 없습니다.",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: "GmarketBold",
                  color: Colors.red,
                ),
              ),
            )
                : Column(
              children: newsItems.map((news) {
                return GestureDetector(  // 클릭을 감지하기 위한 GestureDetector
                  onTap: () {
                    // 뉴스 상세 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewsDetailPage(
                          newsId: news["newsId"] ?? 'defaultId',
                          title: news["title"] ?? '',
                          content: news["content"] ?? '',
                          image: news["image"] ?? '',
                          time: news["time"] ?? '',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          news["image"] != null && news["image"] != ""
                              ? Image.network(
                            news["image"]!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          )
                              : Container(width: 80, height: 80),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  news["title"]!,
                                  style: TextStyle(fontSize: 16, fontFamily: "GmarketBold"),
                                ),
                                Text(
                                  news["content"]!.length > 70
                                      ? '${news["content"]!.substring(0, 70)}...' // 50자 이후 생략
                                      : news["content"]!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontFamily: "GmarketMedium",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
