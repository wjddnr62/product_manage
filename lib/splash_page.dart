import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rehabiltiation/auth_gate.dart';
import 'package:rehabiltiation/main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 로딩 시간을 약간 주어 스플래시 화면이 보이도록 함
    await Future.delayed(const Duration(milliseconds: 500));

    final userBox = Hive.box('user');
    final phoneNumber = userBox.get('phoneNumber');

    if (phoneNumber == null) {
      // Hive에 번호가 없으면 로그인 화면으로
      _navigateToAuthGate();
      return;
    }

    try {
      // Hive에 번호가 있으면 Firestore에서 실제 사용자가 있는지 확인
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Firestore에도 사용자가 존재하면 메인 화면으로
        _navigateToMainPage();
      } else {
        // Firestore에 사용자가 없으면 (예: 삭제된 경우) 로컬 데이터 삭제 후 로그인 화면으로
        await userBox.clear();
        _navigateToAuthGate();
      }
    } catch (e) {
      // 오류 발생 시 안전하게 로그인 화면으로
      _navigateToAuthGate();
    }
  }

  void _navigateToMainPage() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MainPage()),
    );
  }

  void _navigateToAuthGate() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중임을 표시
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
