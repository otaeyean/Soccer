import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '회원가입',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _signUp() {
    final id = _idController.text;
    final password = _passwordController.text;
    final email = _emailController.text;

    print("ID: $id, Password: $password, Email: $email");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원가입'),
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
                  TextSpan(text: '회원님의\n '),
                  TextSpan(
                    text: '계정',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
                  TextSpan(text: '을 만들어주세요.\n\n'),
                ],
              ),
            ),
            SizedBox(height: 20),
            // 아이디 입력란
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
                  border: InputBorder.none, // 테두리 제거
                ),
              ),
            ),
            
            SizedBox(height: 20),
            // 비밀번호 입력란
            Text(
              'PW',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: '비밀번호',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            // 이메일 입력란
            Text(
              'Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: '이메일',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            // 회원가입 버튼
            Center(
              child: SizedBox(
                width: double.infinity, // 버튼을 화면 너비에 맞게 설정
                child: ElevatedButton(
                  onPressed: _signUp,
                  child: Text(
                    '회원가입 하기',
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
