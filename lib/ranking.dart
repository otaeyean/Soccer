import 'package:flutter/material.dart';

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
        Flexible(
          child: Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 40),
                      SizedBox(height: 5),
                      Text('2위'),
                      Text('맨시티'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 40),
                      SizedBox(height: 5),
                      Text('1위'),
                      Text('리버풀'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star, size: 40),
                      SizedBox(height: 5),
                      Text('3위'),
                      Text('노팅엄'),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
        Flexible(
          child: Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/haaland.jpg'),
                      ),
                      SizedBox(height: 5),
                      Text('득점'),
                      Text('홀란-11골'),
                     
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: AssetImage('assets/saka.jpg'),
                      ),
                      SizedBox(height: 5),
                      Text('도움'),
                      Text('사카 - 8도움'),
                      
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Text('10', style: TextStyle(fontSize: 14)),
                      ),
                      SizedBox(height: 5),
                      Text('출장수'),
                      Text('한스 - 10경기'),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columnSpacing: MediaQuery.of(context).size.width * 0.02,
          headingRowColor: MaterialStateProperty.all(purple),
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
            DataColumn(label: Text('승점')),
          ],
          rows: List.generate(10, (index) {
            return DataRow(cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text('팀 ${index + 1}')),
              DataCell(Text('${10 + index}')),
              DataCell(Text('${8 - index}')),
              DataCell(Text('${index % 2}')),
              DataCell(Text('${1 + index}')),
              DataCell(Text('${19 - index}')),
              DataCell(Text('${6 + index}')),
              DataCell(Text('${25 - index}')),
            ]);
          }),
        ),
      ),
    );
  }
}

class PlayerRankingTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: DataTable(
          columnSpacing: MediaQuery.of(context).size.width * 0.02,
          headingRowColor: MaterialStateProperty.all(purple),
          headingTextStyle: TextStyle(color: Colors.white),
          columns: [
            DataColumn(label: Text('순위')),
            DataColumn(label: Text('선수')),
            DataColumn(label: Text('팀')),
            DataColumn(label: Text('경기')),
            DataColumn(label: Text('득점')),
            DataColumn(label: Text('도움')),
          ],
          rows: List.generate(10, (index) {
            return DataRow(cells: [
              DataCell(Text('${index + 1}')),
              DataCell(Text('선수 ${index + 1}')),
              DataCell(Text('팀 ${index + 1}')),
              DataCell(Text('${10 + index}')),
              DataCell(Text('${index * 2}')),
              DataCell(Text('${index + 1}')),
            ]);
          }),
        ),
      ),
    );
  }
}
