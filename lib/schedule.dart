import 'package:flutter/material.dart';
import 'chating.dart'; // chating.dart 파일이 존재해야 합니다.

class SchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  // 왼쪽 화살표 탭 처리
                },
                child: Text(
                  '←',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
              SizedBox(width: 13),
              Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  '11.05(화)',
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'KBO_Medium',
                  ),
                ),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  // 오른쪽 화살표 탭 처리
                },
                child: Text(
                  '→',
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // 실제 아이템 개수로 변경하세요
              itemBuilder: (context, index) {
                return GameListItem();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class GameListItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatingPage()), // chating.dart의 ChatingPage 클래스를 호출
        );
      },
      child: Container(
        height: 140,
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Stack(
            children: [
              Positioned(
                left: 45,
                top: 10,
                child: Text(
                  '토트넘',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                right: 45,
                top: 10,
                child: Text(
                  '맨시티',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                left: 65,
                top: 30,
                child: Text(
                  '3',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                right: 65,
                top: 30,
                child: Text(
                  '1',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Text(
                  '토트넘 훗스퍼 스타디움',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Positioned(
                top: 30,
                left: 0,
                right: 0,
                child: Text(
                  '18:30',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17),
                ),
              ),
              Positioned(
                top: 52,
                left: 0,
                right: 0,
                child: Text(
                  '우천취소',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
