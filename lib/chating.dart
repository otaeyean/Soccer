import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatingPage extends StatefulWidget {
  final String team1;
  final String team2;
  final String round;

  ChatingPage({
    required this.team1,
    required this.team2,
    required this.round,
  });

  @override
  _ChatingPageState createState() => _ChatingPageState();
}

class _ChatingPageState extends State<ChatingPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // 문자 중계 메시지 목록

  late String _chatRoomId; // 채팅방 ID

  @override
  void initState() {
    super.initState();
    _chatRoomId = _generateChatRoomId(); // 중계별 고유 채팅방 ID 생성
    fetchRelayMessages(); // 문자 중계 메시지 가져오기
  }

  // 중계 ID 기반으로 채팅방 ID 생성
  String _generateChatRoomId() {
    return '${widget.team1}_${widget.team2}_${widget.round}';
  }

  void fetchRelayMessages() async {
    try {
      // round 값 변환
      final convertedRound = convertRound(widget.round);

      // 쿼리 조건 출력 (확인용)
      print("Fetching match data...");
      print("Team1: ${widget.team1}, Team2: ${widget.team2}, Round: $convertedRound");

      // matches 컬렉션에서 home과 away를 teams 객체 내에서 찾기
      final query = FirebaseFirestore.instance
          .collection('matches')
          .where('teams.home', isEqualTo: widget.team1) // teams.home 사용
          .where('teams.away', isEqualTo: widget.team2) // teams.away 사용
          .where('leagueInfo', isEqualTo: convertedRound);

      // 쿼리 실행
      final matchDoc = await query.get();

      if (matchDoc.docs.isEmpty) {
        print("No match found");
        return;
      }

      // 경기 ID 출력
      final matchId = matchDoc.docs.first.id;
      print("Match found, matchId: $matchId");

      // 해당 경기의 relays 하위 컬렉션에서 first_half, second_half 가져오기
      final relaysSnapshot = await FirebaseFirestore.instance
          .collection('matches')
          .doc(matchId)
          .collection('relays')
          .get();

      if (relaysSnapshot.docs.isEmpty) {
        print("No relays found for this match.");
        return;
      }

      // relays에서 이벤트들 가져오기
      relaysSnapshot.docs.forEach((doc) {
        print("Fetching events from relay: ${doc.id}");
        final events = doc['events'] as List<dynamic>;
        if (events.isEmpty) {
          print("No events found in relay.");
        }

        events.forEach((event) {
          print("Event found: ${event['description']} at ${event['time']}");
          setState(() {
            _messages.add({
              'description': event['description'] ?? '',
              'time': event['time'] ?? '',
            });
          });
        });
      });

    } catch (e) {
      print("Error fetching match data: $e");
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = _messageController.text;

      // Firestore에 채팅 메시지 저장
      FirebaseFirestore.instance
          .collection('matches')
          .doc(_chatRoomId) // 중계별 채팅방
          .collection('chats')
          .add({
        'message': message,
        'sender': 'Anonymous', // 익명 사용자
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _messageController.clear(); // 입력 필드 비우기
      });
    }
  }

  String convertRound(String round) {
    return "프리미어리그 " + round;
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final time = message['time'] ?? ''; // 'time' 필드가 없을 경우 빈 문자열
    final description = message['description'] ?? ''; // 'description' 필드가 없을 경우 빈 문자열

    bool hasTime = time.isNotEmpty;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: hasTime ? Colors.white : Color(0xFF37003C), // 시간 있을 때는 흰색, 없을 때는 배경색 변경
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasTime)
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue, // 시간 강조 색상
                  fontFamily: "GmarketBold", // 폰트 적용
                ),
              ),
            ),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: hasTime ? Colors.black : Colors.white, // 시간 있을 때는 검정, 없을 때는 흰색
                fontFamily: "GmarketBold", // 폰트 적용
              ),
              overflow: TextOverflow.ellipsis, // 텍스트가 길어지면 ... 처리
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFF37003C), width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 12,
            fontFamily: "GmarketMedium", // 폰트 적용
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.team1} vs ${widget.team2} - ${widget.round}', style: TextStyle(fontFamily: "GmarketBold")),
      ),
      body: Column(
        children: [
          // 문자 중계 영역
          Expanded(
            flex: 5, // 문자 중계 영역 비율 (위쪽)
            child: ListView.builder(
              reverse: true, // 메시지를 아래에서 위로 쌓이게 설정
              itemCount: _messages.length, // 문자 중계 리스트의 길이
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message); // Map<String, dynamic>으로 전달
              },
            ),
          ),
          Divider(), // 구분선 추가
          // 채팅 입력 영역
          Expanded(
            flex: 3, // 채팅 입력 영역 비율 (아래쪽)
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('matches')
                        .doc(_chatRoomId) // 중계별 채팅방
                        .collection('chats')
                        .orderBy('timestamp', descending: true) // 최신 메시지부터
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData) {
                        return Center(child: Text('No messages', style: TextStyle(fontFamily: "GmarketBold")));
                      }

                      final chatDocs = snapshot.data!.docs;
                      return ListView.builder(
                        reverse: true, // 아래에서 위로 메시지를 쌓기
                        itemCount: chatDocs.length,
                        itemBuilder: (context, index) {
                          final messageData = chatDocs[index];
                          final message = messageData['message'] as String;
                          return _buildChatBubble(message, true); // true는 자신의 메시지
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: '메시지를 입력하세요',
                            hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                            filled: true, // 배경 색상을 사용
                            fillColor: Colors.white, // 배경 색상 설정
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20), // 둥근 테두리
                              borderSide: BorderSide.none, // 테두리 없앰
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
