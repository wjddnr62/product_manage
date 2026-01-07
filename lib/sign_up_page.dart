import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rehabiltiation/screens/sign_up/enter_name_page.dart';
import 'package:rehabiltiation/screens/sign_up/sign_up_cubit.dart';
import 'package:rehabiltiation/screens/sign_up/sign_up_state.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SignUpCubit(),
      child: const SignUpView(),
    );
  }
}

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 필요'),
        content: const Text('휴대폰 번호를 가져오려면 전화 권한이 필요합니다. 앱 설정에서 권한을 허용해주세요.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('휴대폰 인증'),
      ),
      body: SafeArea(
        child: BlocListener<SignUpCubit, SignUpState>(
          listener: (context, state) {
            if (state is SignUpCodeVerified) {
              // 인증 성공 시 이름 입력 페이지로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EnterNamePage(phoneNumber: state.phoneNumber),
                ),
              );
            } else if (state is SignUpFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            } else if (state is SignUpPermissionPermanentlyDenied) {
              _showPermissionDialog();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    labelText: '인증 코드',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 24),
                BlocBuilder<SignUpCubit, SignUpState>(
                  builder: (context, state) {
                    if (state is SignUpLoading) {
                      return ElevatedButton(
                        onPressed: null, // 로딩 중에는 비활성화
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
                        ),
                      );
                    }
                    return ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        context.read<SignUpCubit>().verifyCode(_codeController.text);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('인증하기'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
