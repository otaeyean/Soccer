import 'package:flutter/material.dart';

class CreatePostPage extends StatelessWidget {
  final Function(String, String) onSubmit;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  CreatePostPage({required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 10,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                onSubmit(titleController.text, contentController.text);
                Navigator.pop(context);
              },
              child: Text('게시글 저장'),
            ),
          ],
        ),
      ),
    );
  }
}
