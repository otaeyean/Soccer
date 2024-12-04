import 'package:flutter/material.dart';

class NewsDetailPage extends StatelessWidget {
  final String newsId;
  final String title;
  final String content;
  final String image;
  final String time;

  NewsDetailPage({
    required this.newsId,
    required this.title,
    required this.content,
    required this.image,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    // 두 개 이상의 연속된 공백을 찾아서 줄바꿈으로 변경
    String formattedContent = content.replaceAll(RegExp(r' {2,}'), '\n\n');

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView( // SingleChildScrollView로 내용 스크롤 가능
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (image.isNotEmpty)
              Image.network(image),  // 이미지가 있으면 표시
            SizedBox(height: 16),
            Text(
              time,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Text(
              formattedContent, // 변경된 content 표시
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
