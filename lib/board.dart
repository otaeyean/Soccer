import 'package:flutter/material.dart';
import 'create_post_page.dart';
import 'post_detail_page.dart';

class BoardPage extends StatefulWidget {
  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  List<Map<String, dynamic>> posts = [
    {
      'username': 'User1',
      'title': '첫 번째 게시글1',
      'commentCount': 5,
      'timestamp': '2024-11-05 10:00',
    },
    {
      'username': 'User2',
      'title': '두 번째 게시글3',
      'commentCount': 3,
      'timestamp': '2024-11-05 11:00',
    },
  ];

  void _addNewPost(String title, String content) {
    setState(() {
      posts.add({
        'username': 'NewUser',
        'title': title,
        'commentCount': 0,
        'timestamp': DateTime.now().toString().substring(0, 16),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center( // 제목을 중앙 정렬
          child: Text(
            '자유게시판',
            style: TextStyle(fontSize: 20), // 앱바 제목 크기 조정
          ),
        ),
        automaticallyImplyLeading: false, // 뒤로가기 버튼 제거
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListTile(
                title: Text(
                  posts[index]['title'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // 제목 글자 크기 증가
                ),
                subtitle: Text(
                  '${posts[index]['username']} • 댓글 ${posts[index]['commentCount']}개 • ${posts[index]['timestamp']}',
                  style: TextStyle(fontSize: 14, color: Colors.grey), // 부제목 글자 크기 축소 및 색상 설정
                ),
                trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey), // 화살표 추가
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailPage(post: posts[index]),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreatePostPage(onSubmit: _addNewPost),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
