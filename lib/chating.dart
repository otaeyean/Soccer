import 'package:flutter/material.dart';

class ChatingPage extends StatefulWidget {
  @override
  _ChatingPageState createState() => _ChatingPageState();
}

class _ChatingPageState extends State<ChatingPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = []; // 문자 중계 메시지 목록
  final List<String> _chatMessages = []; // 채팅 메시지 목록

  @override
  void initState() {
    super.initState();
    // 더미 문자 중계 메시지 추가
    _messages.addAll([
      '⚽  1분: 경기 시작되었습니다!',
      '⚽  15분: 선수 A가 멋진 드리블을 보여주었습니다!',
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('축구 문자 중계 및 채팅'),
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
                return _buildMessageBubble(_messages[_messages.length - 1 - index]);
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
                  child: ListView.builder(
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      return _buildChatBubble(_chatMessages[index], true); // true는 자신의 메시지
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
                            filled: true, // 배경 색상을 사용
                            fillColor: Colors.white, // 배경 색상 설정
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20), // 둥근 테두리
                              borderSide: BorderSide.none, // 테두리 제거
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

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _chatMessages.add(_messageController.text); // 채팅 메시지 추가
        _messageController.clear(); // 입력 필드 비우기
      });
    }
  }

  Widget _buildMessageBubble(String message) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 14),
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
          border: Border.all(color: Color(0xFF37003C), width: 1), // #37003C로 변경
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message,
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
