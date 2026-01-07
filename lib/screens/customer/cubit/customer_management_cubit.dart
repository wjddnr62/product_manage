import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        // 다시 고객 목록 상태로 돌아가기 위해 잠시 후 loadCustomers 호출
        Future.delayed(const Duration(seconds: 2), () => loadCustomers());
        return;
      }
      await _customerRepository.addCustomer(
        name: name,
        phoneNumber: phoneNumber,
        gender: gender,
        age: age,
      );
      // 성공 시 스트림이 자동으로 목록을 갱신하므로 별도 상태 변경 필요 없음
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
