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
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');

    setState(() {
      _isLoggedIn = userName != null && userName.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            '자유게시판',
            style: TextStyle(
              fontSize: 20,
              fontFamily: "GmarketBold",
              color: Colors.white,  // 텍스트 색상을 흰색으로 변경
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor:const Color.fromARGB(255, 20, 40, 153),  // 네이비 색상 배경 적용
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
                    title: Text(
                      post['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: "GmarketBold",
                      ),
                    ),
                    subtitle: Text(
                      '${post['username']} • 댓글 ${post['commentCount']}개 • ${post['timestamp'].toDate().toString().substring(0, 16)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: "GmarketMedium",
                      ),
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
            : null,
        child: Icon(Icons.add, color: Colors.white),  // 아이콘 색상을 흰색으로 변경
        backgroundColor: _isLoggedIn ? const Color.fromARGB(255, 20, 40, 153) : Colors.grey,  // 네이비 색상 또는 회색 적용
      ),
    );
  }
}
