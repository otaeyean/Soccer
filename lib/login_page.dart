import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();  // 이메일 입력
  final TextEditingController _passwordController = TextEditingController();  // 비밀번호 입력

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();  // 이메일
    final password = _passwordController.text.trim();  // 비밀번호

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('이메일과 비밀번호를 입력해주세요')),
      );
      return;
    }

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      print("로그인 성공: ${userCredential.user?.email}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 성공')),
      );

      // Firestore에서 유저 이름 가져오기
      String? userName = await _getUserNameFromFirestore(userCredential.user!.uid);

      // SharedPreferences에 유저 이름 저장
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', userName ?? ''); // 유저 이름 저장

      // 로그인 후 바로 사이드바를 갱신하기 위해 상태 업데이트
      setState(() {
        userName = userName ?? '';  // 상태 갱신
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),  // 새로고침된 상태로 이동
      );

    } on FirebaseAuthException catch (e) {
      print("로그인 실패: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: ${e.message}')),
      );
    }
  }

  // Firestore에서 유저 이름 가져오기
  Future<String?> _getUserNameFromFirestore(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        return snapshot['nickname'];  // Firestore에서 'nickname' 필드를 가져옴
      }
    } catch (e) {
      print('Firestore에서 유저 이름 가져오기 실패: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '로그인',
          style: TextStyle(fontFamily: "GmarketBold"),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 60),
            RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontFamily: "GmarketBold",
                ),
                children: [
                  TextSpan(text: ' 반갑습니다!\n '),
                  TextSpan(
                    text: '로그인',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontFamily: "GmarketBold",
                    ),
                  ),
                  TextSpan(text: '을 해주세요.\n\n'),
                ],
              ),
            ),
            // 이메일 입력란
            Text('Email', style: TextStyle(fontSize: 16, fontFamily: "GmarketBold")),
            SizedBox(height: 8),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: '이메일을 입력해주세요',
                hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            // 비밀번호 입력란
            Text('PW', style: TextStyle(fontSize: 16, fontFamily: "GmarketBold")),
            SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: '비밀번호를 입력해주세요',
                hintStyle: TextStyle(fontFamily: "GmarketMedium"),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 30),
            // 로그인 버튼
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text(
                    '로그인',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "GmarketBold",
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF37003C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}