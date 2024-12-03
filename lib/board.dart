import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_post_page.dart';
import 'post_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BoardPage extends StatefulWidget {
  @override
  _BoardPageState createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoggedIn = false;  // 로그인 여부를 관리할 변수ㅅ

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();  // 로그인 상태 확인
  }

  // SharedPreferences에서 로그인 상태 확인
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');

    setState(() {
      _isLoggedIn = userName != null && userName.isNotEmpty;  // userName 값이 있으면 로그인 상태
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('자유게시판', style: TextStyle(fontSize: 20, fontFamily: "GmarketBold")),
        ),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(
                    title: Text(post['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "GmarketBold")),
                    subtitle: Text(
                      '${post['username']} • 댓글 ${post['commentCount']}개 • ${post['timestamp'].toDate().toString().substring(0, 16)}',
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: "GmarketMedium"),
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PostDetailPage(postId: post.id)),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoggedIn
            ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostPage()));
        }
            : null,  // 로그인되지 않은 경우 버튼을 비활성화
        child: Icon(Icons.add),
        backgroundColor: _isLoggedIn ? Colors.blue : Colors.grey,  // 로그인 상태에 따라 버튼 색상 변경
      ),
    );
  }
}
