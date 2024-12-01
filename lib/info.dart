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
    String homeStadium = '';
  final Color customColor = Color(0xFF37003C);

  final List<String> teamArray = [
    '팀 선택',
    '리버풀 FC',
    '브라이튼 앤 호브 알비온 FC',
    '맨체스터 시티 FC',
    '첼시 FC',
    '아스널 FC',
    '토트넘 홋스퍼',
    '노팅엄 포레스트 FC',
    '애스턴 빌라 FC',
    '풀럼 FC',
    '뉴캐슬 유나이티드',
    '브렌트포트 FC',
    '맨체스터 유나이티드',
    'AFC 본머스',
    '웨스트햄 유나이티드',
    '에버턴 FC',
    '레스터 시티 FC',
    '울버햄튼 원더러스 FC',
    '입스위치 타운',
    '크리스탈 팰리스 FC',
    '사우샘프턴 FC'
  ];

    final Map<String, String> teamStadiums = {
    'AFC 본머스': '바이탈리티 스타디움',
    '노팅엄 포레스트 FC': '시티 그라운드',
    '뉴캐슬 유나이티드': '세인트 제임스 파크',
    '레스터 시티 FC': '킹파워 스타디움',
    '리버풀 FC': '안필드',
    '맨체스터 시티 FC': '에티하드 스타디움',
    '맨체스터 유나이티드': '올드 트래포드',
    '브라이튼 앤 호브 알비온 FC': '아멕스 스타디움',
    '브렌트포트 FC': '지텍 커뮤니티 스타디움',
    '사우샘프턴 FC': '세인트 메리스 스타디움',
    '아스널 FC': '에미레이츠 스타디움',
    '애스턴 빌라 FC': '빌라 파크',
    '에버턴 FC': '구디슨 파크',
    '울버햄튼 원더러스 FC': '몰리뉴 스타디움',
    '웨스트햄 유나이티드': '런던 스타디움',
    '입스위치 타운': '포트먼 로드',
    '첼시 FC': '스탬포드 브릿지',
    '크리스탈 팰리스 FC': '셀허스트 파크',
    '토트넘 홋스퍼': '토트넘 홋스퍼 스타디움',
    '풀럼 FC': '크레이븐 코티지',
  };

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
        title: Text('팀 선수 목록', style: TextStyle(fontFamily: "GmarketBold")),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '홈구장: \n$homeStadium',
                  style: TextStyle(fontSize: 17, fontFamily: "GmarketMedium"),
                ),
                DropdownButton<String>(
                  value: selectedTeam,
                  icon: Icon(Icons.arrow_downward, color: customColor),
                  iconSize: 26,
                  elevation: 25,
                  style: TextStyle(fontSize: 15, color: customColor,fontFamily: "GmarketMedium"),
                  underline: Container(height: 2, color: customColor),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedTeam = newValue!;
                      homeStadium = teamStadiums[selectedTeam] ?? '';
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
                  return Center(child: Text('선수 데이터가 없습니다.', style: TextStyle(fontSize: 17, fontFamily: "GmarketBold")));
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
                      style: TextStyle(fontSize: 22, fontFamily: "GmarketBold"),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '번호: $number',
                          style: TextStyle(fontSize: 18, fontFamily: "GmarketMedium"),
                        ),
                        SizedBox(width: 10),
                        Text(
                          '포지션: $position',
                          style: TextStyle(fontSize: 18, fontFamily: "GmarketMedium"),
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