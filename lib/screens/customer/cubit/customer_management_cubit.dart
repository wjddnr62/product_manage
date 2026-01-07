import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:rehabiltiation/repositories/customer_repository.dart';
import 'package:rehabiltiation/screens/customer/cubit/customer_management_state.dart';

class CustomerManagementCubit extends Cubit<CustomerManagementState> {
  final CustomerRepository _customerRepository;
  StreamSubscription? _customerSubscription;

  CustomerManagementCubit(this._customerRepository) : super(CustomerManagementInitial());

  // 고객 목록 불러오기
  void loadCustomers() {
    _customerSubscription?.cancel();
    _customerSubscription = _customerRepository.getCustomers().listen((customers) {
      emit(CustomerManagementLoaded(customers));
    }, onError: (error) {
      emit(CustomerManagementError(error.toString()));
    });
  }

  // 고객 추가
  Future<void> addCustomer({
    required String name,
    required String phoneNumber,
    required String gender,
    int? age,
  }) async {
    try {
      final isDuplicate = await _customerRepository.isPhoneNumberDuplicate(phoneNumber);
      if (isDuplicate) {
        emit(CustomerManagementError('이미 등록된 고객 번호입니다.'));
        Future.delayed(const Duration(seconds: 2), () => loadCustomers());
        return;
      }

      // Hive에서 현재 로그인한 관리자 uid 가져오기
      final userBox = Hive.box('user');
      final registeredByUid = userBox.get('uid') as String?;

      if (registeredByUid == null) {
        emit(CustomerManagementError('로그인 정보를 찾을 수 없습니다. 다시 로그인 해주세요.'));
        Future.delayed(const Duration(seconds: 2), () => loadCustomers());
        return;
      }

      await _customerRepository.addCustomer(
        name: name,
        phoneNumber: phoneNumber,
        gender: gender,
        age: age,
        registeredBy: registeredByUid,
      );
    } catch (e) {
      emit(CustomerManagementError(e.toString()));
      Future.delayed(const Duration(seconds: 2), () => loadCustomers());
    }
  }

  @override
  Future<void> close() {
    _customerSubscription?.cancel();
    return super.close();
  }
}
