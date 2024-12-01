import 'package:flutter/material.dart';

class BoardDetailPage extends StatefulWidget {
  final String title;
  final String author;
  final String date;

  BoardDetailPage({required this.title, required this.author, required this.date});

  @override
  _BoardDetailPageState createState() => _BoardDetailPageState();
}

class _BoardDetailPageState extends State<BoardDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, String>> comments = [
    {"author": "팬6", "content": "좋은 글이네요!", "date": "2024-11-06"},
    {"author": "팬7", "content": "동의합니다.", "date": "2024-11-06"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세', style: TextStyle(fontFamily: "GmarketBold"))
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 24, fontFamily: "GmarketBold"),
            ),
            SizedBox(height: 8),
            Text(
              '${widget.author} • ${widget.date}',
              style: TextStyle(color: Colors.grey[600], fontFamily: "GmarketMedium"),
            ),
            SizedBox(height: 16),
            Text(
              '여기에 게시글 내용이 들어갑니다. 이는 실제 데이터로 대체되어야 합니다.',
              style: TextStyle(fontSize: 16, fontFamily: "GmarketMedium"),
            ),
            SizedBox(height: 24),
            Divider(thickness: 1),
            SizedBox(height: 16),
            Text(
              '댓글',
              style: TextStyle(fontSize: 20, fontFamily: "GmarketBold"),
            ),
            SizedBox(height: 16),
            ...comments.map((comment) => _buildCommentWidget(comment)).toList(),
            SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: '댓글을 입력하세요',
                hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _addComment,
                ),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentWidget(Map<String, String> comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment['author']!,
            style: TextStyle(fontFamily: "GmarketBold"),
          ),
          SizedBox(height: 4),
          Text(comment['content']!, style: TextStyle(fontFamily: "GmarketMedium"),),
          SizedBox(height: 4),
          Text(
            comment['date']!,
            style: TextStyle(color: Colors.grey[600], fontSize: 12, fontFamily: "GmarketLight"),
          ),
        ],
      ),
    );
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add({
          "author": "현재 사용자",
          "content": _commentController.text,
          "date": DateTime.now().toString().substring(0, 10),
        });
        _commentController.clear();
      });
    }
  }
}