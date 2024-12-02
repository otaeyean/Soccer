 import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color purple = Color(0xFF37003C);

class RankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 두 개의 탭을 사용
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  '팀',
                  style: TextStyle(
                    fontFamily: 'GmarketSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  '선수',
                  style: TextStyle(
                    fontFamily: 'GmarketSans',
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          toolbarHeight: 10,
        ),
        body: TabBarView(
          children: [
            TeamRankingView(), //팀 내용 출력
            PlayerRankingView(),//선수 내용 출력
          ],
        ),
      ),
    );
  }
}
class TeamRankingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('team_ranks')
              .orderBy('순위', descending: false)
              .limit(3)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("데이터가 없음"));
            }

            final topTeams = snapshot.data!.docs;
            topTeams.sort((a, b) {
              if (a['순위'] == 2) return -1;
              if (b['순위'] == 2) return 1;
              return a['순위'].compareTo(b['순위']);
            });

            return Container(
              padding: EdgeInsets.all(15.0),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(topTeams.length, (index) {
                  final team = topTeams[index].data();
                  double iconSize = 30.0;
                  if (team['순위'] == 1) iconSize = 80.0;
                  if (team['순위'] == 2) iconSize = 60.0;
                  if (team['순위'] == 3) iconSize = 60.0;
                  String teamLogo = 'assets/images/${team['팀']}.png';
                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                         SizedBox(height: team['순위'] == 1 ? 0 : 20), // 1위는 높이 0, 나머지는 여백 추가
                        Image.asset(
                          teamLogo,
                          width: iconSize,
                          height: iconSize,
                           fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/노팅엄.png',
                              width: iconSize,
                              height: iconSize,
                              fit: BoxFit.cover, 
                            );
                          },
                        ),
                        SizedBox(height: 5),
                        Text(
                          '순위 ${team['순위']}',
                          style: TextStyle(
                            fontFamily: 'GmarketSans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          team['팀'],
                          style: TextStyle(
                            fontFamily: 'GmarketSans',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: TeamRankingTable(),
          ),
        ),
      ],
    );
  }
}
class PlayerRankingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('player_ranks')
              .orderBy('순위')
              .limit(3)
              .get(),
          builder: (context, playerSnapshot) {
            if (playerSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!playerSnapshot.hasData || playerSnapshot.data!.docs.isEmpty) {
              print("player_ranks에서 데이터를 찾을 수 없습니다.");
              return Center(child: Text("No player ranking data available."));
            }

            final topPlayers = playerSnapshot.data!.docs;
            final playerNames = topPlayers.map((doc) => doc['선수']).toList();
            print("선수 목록: $playerNames");

            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('team_players')
                  .where('name', whereIn: playerNames)
                  .get(),
              builder: (context, imageSnapshot) {
                if (imageSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!imageSnapshot.hasData || imageSnapshot.data!.docs.isEmpty) {
                  print("team_players에서 이미지 데이터를 찾을 수 없습니다: $playerNames");
                  return Center(child: Text("No image data found."));
                }

                  final playerImages = imageSnapshot.data!.docs;

                // 2위, 1위, 3위 순으로 재정렬
                playerImages.sort((a, b) {
                  final rankA = topPlayers.firstWhere(
                    (doc) => doc['선수'] == a['name'],
                  )['순위'];
                  final rankB = topPlayers.firstWhere(
                    (doc) => doc['선수'] == b['name'],
                  )['순위'];

                  if (rankA == 2) return -1; // 2위 먼저
                  if (rankA == 1) return 0;  // 1위 다음
                  return 1; // 3위 마지막
                });
                return Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: playerImages.map((playerDoc) {
                      final playerData = playerDoc.data();
                      double iconSize = 40.0;

                      final rank = topPlayers.firstWhere(
                        (doc) => doc['선수'] == playerData['name'],
                      )['순위'];
                      if (rank == 1) iconSize = 50.0;
                      if (rank == 2) iconSize = 40.0;

                      String fullImageUrl = playerData['image_url'].startsWith('//')
                          ? 'https:' + playerData['image_url']  // 상대 URL을 절대 URL로 변경
                          : playerData['image_url'];

                      if (fullImageUrl.startsWith('file://')) {
                        print("잘못된 URL 포맷: $fullImageUrl");
                        fullImageUrl = '';
                      }

                      print("최종 이미지 URL: $fullImageUrl");

                      return Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: iconSize,
                              backgroundImage: fullImageUrl.isNotEmpty
                                  ? NetworkImage(fullImageUrl)
                                  : AssetImage('assets/default_player.jpg'),
                              onBackgroundImageError: (error, stackTrace) {
                                print("이미지 로드 실패 - 선수: ${playerData['name']}, URL: $fullImageUrl, Error: $error");
                              },
                            ),
                            SizedBox(height: 5),
                            Text(
                              playerData['name'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${rank}위',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            );
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: PlayerRankingTable(),
          ),
        ),
      ],
    );
  }
}


class TeamRankingTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('team_ranks')
          .orderBy('순위')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No data available"));
        }

        final teamRanks = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: MediaQuery.of(context).size.width * 0.02,
            headingRowColor: MaterialStateProperty.all(purple),
              headingTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'GmarketSans',
              fontWeight: FontWeight.bold,
            ),
            columns: [
              DataColumn(label: Text('순위')),
              DataColumn(label: Text('            팀명')),
              DataColumn(label: Text('경기')),
              DataColumn(label: Text('승')),
              DataColumn(label: Text('무')),
              DataColumn(label: Text('패')),
              DataColumn(label: Text('득점')),
              DataColumn(label: Text('실점')),
              DataColumn(label: Text('득실차')),
              DataColumn(label: Text('승점')),
            ],
            rows: teamRanks.map((team) {
              final data = team.data();
              String teamLogo = 'assets/images/${data['팀']}.png';  // 로고 이미지 경로

              return DataRow(cells: [
                DataCell(Text('${data['순위']}',style: mediumTextStyle())),
                DataCell(Row(
                  children: [
                    Image.asset(
                      teamLogo,
                      width: 40.0,
                      height: 40.0,
                      errorBuilder: (context, error, stackTrace) {
                        // 로고가 없을 경우 기본 로고 사용
                        return Image.asset(
                          'assets/default_logo.png',
                          width: 40.0,
                          height: 40.0,
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    Text(data['팀'] ?? '',style: boldTextStyle()),
                  ],
                )),
                DataCell(Text('${data['경기']}',style: mediumTextStyle())),
                DataCell(Text('${data['승']}',style: mediumTextStyle())),
                DataCell(Text('${data['무']}',style: mediumTextStyle())),
                DataCell(Text('${data['패']}',style: mediumTextStyle())),
                DataCell(Text('${data['득점']}',style: mediumTextStyle())),
                DataCell(Text('${data['실점']}',style: mediumTextStyle())),
                DataCell(Text('${data['득실차']}',style: mediumTextStyle())),
                DataCell(Text('${data['승점']}',style: mediumTextStyle())),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}


class PlayerRankingTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirebaseFirestore.instance
          .collection('player_ranks')
          .orderBy('순위') // '순위'로 정렬
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No data available"));
        }

        final playerRanks = snapshot.data!.docs;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: MediaQuery.of(context).size.width * 0.02,
            headingRowColor: WidgetStateProperty.all(purple),
           headingTextStyle: TextStyle(
              color: Colors.white,
              fontFamily: 'GmarketSans',
              fontWeight: FontWeight.bold,
            ),
            columns: [
              DataColumn(label: Text('순위')),
              DataColumn(label: Text('  선수')),
              DataColumn(label: Text('팀')),
              DataColumn(label: Text('경기')),
              DataColumn(label: Text('득점')),
              DataColumn(label: Text('도움')),
              DataColumn(label: Text('슈팅')),
              DataColumn(label: Text('유효슈팅')),
              DataColumn(label: Text('경고')),
              DataColumn(label: Text('퇴장')),
            ],
            rows: playerRanks.map((player) {
              final data = player.data();
              return DataRow(cells: [
                DataCell(Text('${data['순위']}',style: mediumTextStyle())),
                DataCell(Text(data['선수'] ?? '',style: boldTextStyle())),
                DataCell(Text(data['팀'] ?? '',style: mediumTextStyle())),
                DataCell(Text('${data['경기']}',style: mediumTextStyle())),
                DataCell(Text('${data['득점']}',style: mediumTextStyle())),
                DataCell(Text('${data['도움']}',style: mediumTextStyle())),
                DataCell(Text('${data['슈팅']}',style: mediumTextStyle())),
                DataCell(Text('${data['유효슈팅']}',style: mediumTextStyle())),
                DataCell(Text('${data['경고']}',style: mediumTextStyle())),
                DataCell(Text('${data['퇴장']}',style: mediumTextStyle())),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}
  TextStyle mediumTextStyle() {
    return TextStyle(
      fontFamily: 'GmarketSans',
      fontWeight: FontWeight.w500,
    );
  }
TextStyle boldTextStyle() {
  return TextStyle(
    fontFamily: 'GmarketSans',
    fontWeight: FontWeight.bold,
  );
}