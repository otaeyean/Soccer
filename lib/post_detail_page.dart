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
      _userName = prefs.getString('userName');
      _isUserNameLoaded = true;
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
        backgroundColor: Colors.indigo,
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
                Text(post['title'], style: TextStyle(fontSize: 28, fontFamily: "GmarketBold")),
                SizedBox(height: 8),
                Text(
                  '작성자: ${post['username']} • ${post['timestamp'].toDate().toString().substring(0, 16)}',
                  style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: "GmarketMedium"),
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    post['content'],
                    style: TextStyle(fontSize: 16, fontFamily: "GmarketMedium"),
                  ),
                ),
                Divider(height: 32),
                Text('댓글', style: TextStyle(fontSize: 20, fontFamily: "GmarketBold")),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore.collection('posts').doc(widget.postId).collection('comments').orderBy('timestamp').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var comment = snapshot.data!.docs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '댓글 작성자 : ${comment['username']}',
                                      style: TextStyle(
                                        fontFamily: "GmarketLight",
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      comment['content'],
                                      style: TextStyle(fontFamily: "GmarketMedium", fontSize: 14),
                                    ),
                                    if (user != null && comment['username'] == _userName)
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red, size: 20),
                                          onPressed: () => _deleteComment(comment.id, comment['username']),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                if (user != null)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            labelText: '댓글 작성',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            labelStyle: TextStyle(fontFamily: "GmarketMedium"),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.indigo),
                        onPressed: () => _addComment(_commentController.text),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
