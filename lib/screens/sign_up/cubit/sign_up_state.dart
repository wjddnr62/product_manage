import 'package:flutter/foundation.dart';

@immutable
abstract class SignUpState {
  const SignUpState();
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

// 인증 코드 검증 및 전화번호 조회까지만 성공했을 때의 상태
class SignUpCodeVerified extends SignUpState {
  final String phoneNumber;
  const SignUpCodeVerified(this.phoneNumber);
}

class SignUpSuccess extends SignUpState {
  final String message;
  const SignUpSuccess(this.message);
}

class SignUpFailure extends SignUpState {
  final String error;
  const SignUpFailure(this.error);
}

// 권한이 영구적으로 거부되었을 때를 위한 별도 상태
class SignUpPermissionPermanentlyDenied extends SignUpState {}
