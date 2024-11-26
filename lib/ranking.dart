import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color purple = Color(0xFF37003C);

class RankingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('순위'),
          bottom: TabBar(
            tabs: [
              Tab(text: '팀'),
              Tab(text: '선수'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TeamRankingView(),
            PlayerRankingView(),
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
        // 동적인 상단 부분
        FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('team_ranks')
              .orderBy('순위', descending: false)
              .limit(3) // 상위 3팀만 가져옴
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No data available"));
            }

            final topTeams = snapshot.data!.docs;

            // 순위별 아이콘 크기를 다르게 조정
            return Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(topTeams.length, (index) {
                  final team = topTeams[index].data();
                  double iconSize = 30.0;

                  // 순위에 따라 아이콘 크기 설정
                  if (team['순위'] == 1) iconSize = 60.0;
                  if (team['순위'] == 2) iconSize = 50.0;
                  if (team['순위'] == 3) iconSize = 40.0;

                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, size: iconSize),
                        SizedBox(height: 5),
                        Text('순위 ${team['순위']}'),
                        Text(team['팀']),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
        // 테이블
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
        // 동적인 상단 부분
        FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('player_ranks')
              .orderBy('득점', descending: true)
              .limit(3) // 상위 3명만 가져옴
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text("No data available"));
            }

            final topPlayers = snapshot.data!.docs;

            // 순위별 아이콘 크기를 다르게 조정
            return Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(topPlayers.length, (index) {
                  final player = topPlayers[index].data();
                  double iconSize = 30.0;

                  // 순위에 따라 아이콘 크기 설정
                  if (player['순위'] == 1) iconSize = 50.0;
                  if (player['순위'] == 2) iconSize = 45.0;
                  if (player['순위'] == 3) iconSize = 40.0;

                  return Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: iconSize,
                          backgroundImage: NetworkImage(player['profile_image'] ?? 'assets/default_player.jpg'),
                        ),
                        SizedBox(height: 5),
                        Text('${player['선수']} - ${player['득점']}골'),
                      ],
                    ),
                  );
                }),
              ),
            );
          },
        ),
        // 테이블
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
            headingRowColor: WidgetStateProperty.all(purple),
            headingTextStyle: TextStyle(color: Colors.white),
            columns: [
              DataColumn(label: Text('순위')),
              DataColumn(label: Text('팀')),
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
              return DataRow(cells: [
                DataCell(Text('${data['순위']}')),
                DataCell(Text(data['팀'] ?? '')),
                DataCell(Text('${data['경기']}')),
                DataCell(Text('${data['승']}')),
                DataCell(Text('${data['무']}')),
                DataCell(Text('${data['패']}')),
                DataCell(Text('${data['득점']}')),
                DataCell(Text('${data['실점']}')),
                DataCell(Text('${data['득실차']}')),
                DataCell(Text('${data['승점']}')),
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
            headingTextStyle: TextStyle(color: Colors.white),
            columns: [
              DataColumn(label: Text('순위')),
              DataColumn(label: Text('선수')),
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
                DataCell(Text('${data['순위']}')),
                DataCell(Text(data['선수'] ?? '')),
                DataCell(Text(data['팀'] ?? '')),
                DataCell(Text('${data['경기']}')),
                DataCell(Text('${data['득점']}')),
                DataCell(Text('${data['도움']}')),
                DataCell(Text('${data['슈팅']}')),
                DataCell(Text('${data['유효슈팅']}')),
                DataCell(Text('${data['경고']}')),
                DataCell(Text('${data['퇴장']}')),
              ]);
            }).toList(),
          ),
        );
      },
    );
  }
}