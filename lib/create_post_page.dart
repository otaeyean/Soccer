import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  bool _isLoading = false;
  bool _isUserNameLoaded = false;
  String? _userName;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
    _loadUserName();
  }

  // SharedPreferences에서 userName을 불러오는 함수
  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName');  // userName 값 불러오기
      _isUserNameLoaded = true;  // 값이 로드되었음을 표시
    });
  }

  void _createPost(BuildContext context) async {
    if (_user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글을 작성하려면 로그인이 필요합니다.')),
      );
      return;
    }

    if (!_isUserNameLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보를 불러오는 중입니다. 잠시만 기다려주세요.')),
      );
      return;
    }

    String username = _userName ?? '익명';

    if (titleController.text.trim().isEmpty || contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목과 내용을 모두 입력해주세요.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'title': titleController.text.trim(),
        'content': contentController.text.trim(),
        'userId': _user!.uid,
        'username': username,
        'timestamp': DateTime.now(),  // timestamp가 null일 경우 현재 시간 사용
        'commentCount': 0,
      });

      Navigator.pop(context);  // 게시글 작성 후 뒤로 가기
    } catch (e) {
      print("게시글 작성 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('게시글 작성 중 오류가 발생했습니다.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('게시글 작성', style: TextStyle(fontFamily: "GmarketBold")),
        ),
        body: Center(
          child: Text('로그인이 필요합니다.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 작성', style: TextStyle(fontFamily: "GmarketBold")),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())  // 로딩 중
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontFamily: "GmarketMedium"),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: contentController,
              decoration: InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
                labelStyle: TextStyle(fontFamily: "GmarketMedium"),
              ),
              maxLines: 10,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _createPost(context),  // 게시글 저장
              child: Text('게시글 저장', style: TextStyle(fontFamily: "GmarketBold")),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF37003C),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}