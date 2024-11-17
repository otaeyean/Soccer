import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    final id = _idController.text;
    final password = _passwordController.text;

    print("ID: $id, Password: $password");
    // 로그인 로직 추가
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 안내 텍스트
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(text: '반갑습니다!\n '),
                  TextSpan(
                    text: '로그인',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  TextSpan(text: '을 해주세요.\n\n'),
                ],
              ),
            ),
            SizedBox(height: 20),
            // ID 입력란
            Text(
              'ID',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: '아이디를 입력해주세요',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            // 비밀번호 입력란
            Text(
              'PW',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력해주세요',
                  border: InputBorder.none,
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 20),
            // 로그인 버튼
            Center(
              child: SizedBox(
                width: double.infinity, // 버튼을 화면 너비에 맞게 설정
                child: ElevatedButton(
                  onPressed: _login,
                  child: Text(
                    '로그인',
                    style: TextStyle(color: Colors.white),
                  ),
                    style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF37003C), // 버튼 배경색
                    foregroundColor: Colors.white, // 버튼 색상
                    padding: EdgeInsets.symmetric(vertical: 15), // 버튼 높이
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 둥근 모서리
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
