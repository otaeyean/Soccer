import 'package:flutter/material.dart';

class PostDetailPage extends StatefulWidget {
  final Map<String, dynamic> post;

  PostDetailPage({required this.post});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  List<String> comments = [
    '첫 번째 댓글입니다.',
    '두 번째 댓글입니다.',
  ];

  void _addNewComment(String comment) {
    setState(() {
      comments.add(comment);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post['title'],
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '작성자: ${widget.post['username']} • ${widget.post['timestamp']}',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              '게시글 내용이 여기에 표시됩니다.',
              style: TextStyle(fontSize: 16),
            ),
            Divider(height: 32),
            Text(
              '댓글',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(comments[index]),
                  );
                },
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: '댓글 작성',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                _addNewComment(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
