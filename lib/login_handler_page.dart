import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_phone_number/get_phone_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rehabiltiation/main_page.dart';

class LoginHandlerPage extends StatefulWidget {
  const LoginHandlerPage({super.key});

  @override
  State<LoginHandlerPage> createState() => _LoginHandlerPageState();
}

class _LoginHandlerPageState extends State<LoginHandlerPage> {

  Future<void> _loginWithPhoneNumber() async {
    // 1. 휴대폰 번호 가져오기
    String? phoneNumber;
    try {
      phoneNumber = await GetPhoneNumber().get();
    } on PlatformException catch (e) {
      debugPrint('Failed to get phone number: ${e.message}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('휴대폰 번호를 가져올 수 없습니다: ${e.message}')),
      );
      return;
    }

    if (phoneNumber == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SIM이 없거나 번호를 읽을 수 없습니다.')),
      );
      return;
    }

    // 2. Firestore에서 번호 조회
    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (!mounted) return;

      if (query.docs.isNotEmpty) {
        // 3. 회원정보가 있으면 메인 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('로그인 성공: $phoneNumber')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      } else {
        // 4. 회원정보가 없으면 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('회원정보가 없습니다.')),
        );
      }
    } catch (e) {
      debugPrint('Error checking Firestore: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 중 오류가 발생했습니다.')),
      );
    }
  }

  Future<void> _handlePhonePermissionAndLogin() async {
    final phoneStatus = await Permission.phone.status;

    if (phoneStatus.isGranted) {
      await _loginWithPhoneNumber();
    } else if (phoneStatus.isDenied) {
      final result = await Permission.phone.request();
      if (result.isGranted) {
        await _loginWithPhoneNumber();
      }
    } else if (phoneStatus.isPermanentlyDenied) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('권한 필요'),
          content: const Text('로그인을 위해 전화 권한이 필요합니다. 앱 설정에서 권한을 허용해주세요.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.of(context).pop();
              },
              child: const Text('설정으로 이동'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _handlePhonePermissionAndLogin,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          ),
          child: const Text('내 휴대폰 번호로 로그인'),
        ),
      ),
    );
  }
}
