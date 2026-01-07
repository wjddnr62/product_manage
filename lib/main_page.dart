import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rehabiltiation/auth_gate.dart';
import 'package:rehabiltiation/screens/customer/customer_management_page.dart';
import 'package:rehabiltiation/screens/product/product_management_page.dart';
import 'package:rehabiltiation/widgets/double_back_to_exit_wrapper.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  void _logout(BuildContext context) async {
    // Hive에서 사용자 정보 삭제
    final userBox = Hive.box('user');
    await userBox.clear();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AuthGate()),
      (Route<dynamic> route) => false, // 이전의 모든 라우트를 제거
    );
  }

  @override
  Widget build(BuildContext context) {
    return DoubleBackToExitWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('메인 화면'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _logout(context),
              tooltip: '로그아웃',
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CustomerManagementPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('고객 관리'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProductManagementPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('상품 관리'),
                ),
              ],
            ),  
          ),
        ),
      ),
    );
  }
}
