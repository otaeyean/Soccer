import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Player {
  final String name;
  final String number;
  final String position;
  final String imageUrl;

  Player({
    required this.name,
    required this.number,
    required this.position,
    required this.imageUrl,
  });
}

class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  String selectedTeam = '팀 선택';
  final Color customColor = Color(0xFF37003C);
  final List<String> teamArray = [
    '팀 선택',
    'AFC 본머스',
    '노팅엄 포레스트 FC',
    '뉴캐슬 유나이티드',
    '레스터 시티 FC',
    '리버풀 FC',
    '맨체스터 시티 FC',
    '맨체스터 유나이티드',
    '브라이튼 앤 호브 알비온 FC',
    '브렌트포트 FC',
    '사우샘프턴 FC',
    '아스널 FC',
    '애스턴 빌라 FC',
    '에버턴 FC',
    '울버햄튼 원더러스 FC',
    '웨스트햄 유나이티드',
    '입스위치 타운',
    '첼시 FC',
    '크리스탈 팰리스 FC',
    '토트넘 홋스퍼',
    '풀럼 FC'
  ];

  Future<List<Player>>? _playerListFuture;

  @override
  void initState() {
    super.initState();
    _playerListFuture = fetchPlayersFromFirestore(); // 초기 데이터 로드
  }

  Future<List<Player>> fetchPlayersFromFirestore() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    print('Fetching players for team: $selectedTeam'); // 팀 이름 출력

    QuerySnapshot snapshot = await firestore
        .collection('team_players')
        .where('team', isEqualTo: selectedTeam) // 선택한 팀 필터링
        .get();

    if (snapshot.docs.isEmpty) {
      print('No players found for team: $selectedTeam'); // 데이터 없음 확인
    } else {
      print('${snapshot.docs.length} players found for team: $selectedTeam'); // 데이터 수 확인
    }

    return snapshot.docs.map((doc) {
      var firestoreData = doc.data() as Map<String, dynamic>;
      String rawUrl = firestoreData['image_url'] ?? 'https://via.placeholder.com/100';
      String cleanedUrl = rawUrl.startsWith('//') ? 'https:$rawUrl' : rawUrl;

      return Player(
        name: firestoreData['name'] ?? '',
        number: firestoreData['number'].toString(),
        position: firestoreData['position'] ?? '',
        imageUrl: cleanedUrl,
      );
    }).toList();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('팀 선수 목록'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '홈구장:',
                  style: TextStyle(fontSize: 16),
                ),
                DropdownButton<String>(
                  value: selectedTeam,
                  icon: Icon(Icons.arrow_downward, color: customColor),
                  iconSize: 24,
                  elevation: 16,
                  style: TextStyle(color: customColor),
                  underline: Container(height: 2, color: customColor),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTeam = newValue!;
                      _playerListFuture = fetchPlayersFromFirestore();
                    });
                  },
                  items: teamArray.map<DropdownMenuItem<String>>((String value) {
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
            child: FutureBuilder<List<Player>>(
              future: _playerListFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류가 발생했습니다.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('선수 데이터가 없습니다.'));
                } else {
                  final playerList = snapshot.data!;
                  return ListView.builder(
                    itemCount: playerList.length,
                    itemBuilder: (context, index) {
                      final player = playerList[index];
                      return PlayerListItem(
                        name: player.name,
                        number: player.number,
                        position: player.position,
                        imageUrl: player.imageUrl,
                      );
                    },
                  );
                }
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
  final String imageUrl;

  PlayerListItem({
    required this.name,
    required this.number,
    required this.position,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipOval(
                child: Image.network(
                  imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Image load error: $error'); // 디버깅용
                    return Icon(
                      Icons.error_outline, // 대체 아이콘
                      size: 60,
                      color: Colors.red,
                    );
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '번호: $number',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '포지션: $position',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}