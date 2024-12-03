import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PostDetailPage extends StatefulWidget {
  final String postId;

  PostDetailPage({required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _userName;
  bool _isUserNameLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName'); // SharedPreferences에서 userName 가져오기
      _isUserNameLoaded = true; // 로드 완료
    });
  }

  void _addComment(String content) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글을 작성하려면 로그인이 필요합니다.')),
      );
      return;
    }

    if (!_isUserNameLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사용자 정보를 불러오는 중입니다. 잠시만 기다려주세요.')),
      );
      return;
    }

    final username = _userName ?? '익명';

    if (content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 내용을 입력해주세요.')),
      );
      return;
    }

    try {
      await _firestore.collection('posts').doc(widget.postId).collection('comments').add({
        'content': content.trim(),
        'userId': user.uid,
        'username': username,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 댓글 수 증가
      await _firestore.collection('posts').doc(widget.postId).update({
        'commentCount': FieldValue.increment(1),
      });

      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 작성 중 오류가 발생했습니다.')),
      );
    }
  }

  void _deleteComment(String commentId, String commentUserName) async {
    if (_userName != commentUserName) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('본인이 작성한 댓글만 삭제할 수 있습니다.')),
      );
      return;
    }

    try {
      await _firestore.collection('posts').doc(widget.postId).collection('comments').doc(commentId).delete();
      await _firestore.collection('posts').doc(widget.postId).update({
        'commentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 삭제 중 오류가 발생했습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('게시글 상세', style: TextStyle(fontFamily: "GmarketBold")),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('posts').doc(widget.postId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          var post = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: "GmarketBold")),
                SizedBox(height: 8),
                Text('작성자: ${post['username']} • ${post['timestamp'].toDate().toString().substring(0, 16)}',
                    style: TextStyle(color: Colors.grey, fontFamily: "GmarketMedium")),
                SizedBox(height: 16),
                Text(post['content'], style: TextStyle(fontSize: 16, fontFamily: "GmarketMedium")),
                Divider(height: 32),
                Text('댓글', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: "GmarketBold")),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('posts').doc(widget.postId).collection('comments').orderBy('timestamp').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var comment = snapshot.data!.docs[index];
                          return ListTile(
                            title: Text(comment['content'], style: TextStyle(fontFamily: "GmarketMedium")),
                            subtitle: Text(comment['username'], style: TextStyle(fontFamily: "GmarketMedium")),
                            trailing: user != null && comment['username'] == _userName
                                ? IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteComment(comment.id, comment['username']),
                            )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
                if (user != null)
                  TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      labelText: '댓글 작성',
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(fontFamily: "GmarketMedium"),
                    ),
                    onSubmitted: (value) => _addComment(value),
                  )
                else
                  const Text(
                    '로그인 후 댓글을 작성할 수 있습니다.',
                    style: TextStyle(color: Colors.red, fontFamily: "GmarketMedium"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
