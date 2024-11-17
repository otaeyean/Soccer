import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String selectedTeam = '팀 선택';
  final Color customColor = Color(0xFF37003C);

  final List<String> teamArray = ['팀 선택', 'AFC 본머스', '노팅엄 포레스트 FC', '뉴캐슬 유나이티드', 
  '레스터 시티 FC', '리버풀 FC', '맨체스터 시티 FC', '맨체스터 유나이티드', '브라이튼 앤 호브 알비온 FC', 
  '브렌트포드 FC', '사우샘프턴 FC', '아스널 FC', '애스턴 빌라 FC', '에버턴 FC', '울버햄튼 원더러스 FC', 
  '웨스트햄 유나이티드', '입스위치 타운', '첼시 FC', '크리스탈 팰리스 FC', '토트넘 훗스퍼', '풀럼 FC'];

  // 임시 선수 데이터 리스트
  final List<Map<String, String>> playerList = [
    {
      'name': '히샬리송',
      'number': '9',
      'position': '공격수',
      'birthday': '1997.05.10',
      'height': '184cm',
      'weight': '71kg',
    },
      {
    'name': '해리 케인',
    'number': '10',
    'position': '공격수',
    'birthday': '1993.07.28',
    'height': '188cm',
    'weight': '86kg',
  },
  {
    'name': '손흥민',
    'number': '7',
    'position': '공격수',
    'birthday': '1992.07.08',
    'height': '183cm',
    'weight': '78kg',
  },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '홈구장:',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                DropdownButton<String>(
                  value: selectedTeam,
                  icon: Icon(Icons.arrow_downward, color: customColor,),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: customColor),
                  underline: Container(
                    height: 2,
                    color: customColor,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTeam = newValue!;
                    });
                  },
                  items: teamArray
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: playerList.length,
              itemBuilder: (context, index) {
                final player = playerList[index];
                return PlayerListItem(
                  name: player['name']!,
                  number: player['number']!,
                  position: player['position']!,
                  birthday: player['birthday']!,
                  height: player['height']!,
                  weight: player['weight']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerListItem extends StatelessWidget {
  final String name;
  final String number;
  final String position;
  final String birthday;
  final String height;
  final String weight;

  PlayerListItem({
    required this.name,
    required this.number,
    required this.position,
    required this.birthday,
    required this.height,
    required this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 5, top: 2),
                      child: Text(
                        number,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                    SizedBox(width: 8),
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 21,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      birthday,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      height,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      weight,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}