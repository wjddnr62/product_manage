import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:rehabiltiation/main_page.dart';

class EnterNamePage extends StatefulWidget {
  const EnterNamePage({super.key, required this.phoneNumber});

  final String phoneNumber;

  @override
  State<EnterNamePage> createState() => _EnterNamePageState();
}

class _EnterNamePageState extends State<EnterNamePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _completeSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final name = _nameController.text;

    try {
      // 1. 새로운 document 참조를 생성하여 고유 ID를 미리 가져옴
      final userDocRef = FirebaseFirestore.instance.collection('users').doc();

      // 2. Firestore에 사용자 정보 저장
      await userDocRef.set({
        'uid': userDocRef.id, // 고유 ID 저장
        'phoneNumber': widget.phoneNumber,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Hive에 휴대폰 번호 저장
      final userBox = Hive.box('user');
      await userBox.put('phoneNumber', widget.phoneNumber);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name님, 회원가입이 완료되었습니다.')),
      );

      // 메인 페이지로 이동 (모든 이전 스택 제거)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainPage()),
        (route) => false,
      );

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('회원가입 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('이름 입력'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '이름을 입력해주세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeSignUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                        )
                      : const Text('가입 완료'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
