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
    await Future.delayed(const Duration(milliseconds: 500));

    final userBox = Hive.box('user');
    final phoneNumber = userBox.get('phoneNumber');

    if (phoneNumber == null) {
      _navigateToAuthGate();
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        // Firestore에 사용자가 존재하면, uid를 가져와 Hive에 다시 저장
        final userDoc = query.docs.first;
        final userUid = userDoc.data()['uid'] as String?;

        if (userUid != null) {
          await userBox.put('uid', userUid);
          _navigateToMainPage();
        } else {
          // 사용자는 있으나 uid 필드가 없는 비정상 데이터의 경우
          await userBox.clear();
          _navigateToAuthGate();
        }
      } else {
        // 로컬에는 번호가 있으나 DB에는 없는 경우 (삭제된 사용자)
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
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
