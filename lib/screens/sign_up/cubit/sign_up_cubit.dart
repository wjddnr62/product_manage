import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_phone_number/get_phone_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rehabiltiation/screens/sign_up/cubit/sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  SignUpCubit() : super(SignUpInitial());

  Future<void> verifyCode(String enteredCode) async {
    emit(SignUpLoading());

    try {
      // 1. Firestore에서 인증 코드 검증
      final codeQuery = await FirebaseFirestore.instance.collection('code').limit(1).get();
      if (codeQuery.docs.isEmpty) {
        emit(const SignUpFailure('서버에 등록된 인증 코드가 없습니다.'));
        return;
      }
      final validCode = codeQuery.docs.first.data()['number']?.toString();
      if (validCode == null || enteredCode != validCode) {
        emit(const SignUpFailure('인증코드가 일치하지 않습니다'));
        return;
      }

      // 2. 전화 권한 확인 및 요청
      final phoneStatus = await Permission.phone.status;
      if (phoneStatus.isDenied) {
        final result = await Permission.phone.request();
        if (!result.isGranted) {
          emit(const SignUpFailure('전화 권한이 필요합니다.'));
          return;
        }
      } else if (phoneStatus.isPermanentlyDenied) {
        emit(SignUpPermissionPermanentlyDenied());
        return;
      }

      // 3. 휴대폰 번호 가져오기
      String? phoneNumber;
      try {
        phoneNumber = await GetPhoneNumber().get();
      } on PlatformException catch (e) {
        emit(SignUpFailure('휴대폰 번호를 가져올 수 없습니다: ${e.message}'));
        return;
      }
      if (phoneNumber == null) {
        emit(const SignUpFailure('SIM이 없거나 번호를 읽을 수 없습니다.'));
        return;
      }

      // 4. Firestore에 번호 중복 확인
      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (userQuery.docs.isNotEmpty) {
        emit(SignUpFailure('이미 등록된 번호입니다: $phoneNumber'));
        return;
      }

      // 5. 코드 인증 및 번호 확인 완료 상태 전달
      emit(SignUpCodeVerified(phoneNumber));

    } catch (e) {
      emit(SignUpFailure('오류가 발생했습니다: ${e.toString()}'));
    }
  }
}
