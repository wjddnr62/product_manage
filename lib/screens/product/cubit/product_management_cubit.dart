import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/models/product_model.dart';
import 'package:rehabiltiation/repositories/customer_repository.dart';
import 'package:rehabiltiation/repositories/product_repository.dart';
import 'package:rehabiltiation/repositories/user_repository.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_state.dart';

class ProductManagementCubit extends Cubit<ProductManagementState> {
  final ProductRepository _productRepository;
  final CustomerRepository _customerRepository;
  final UserRepository _userRepository;
  StreamSubscription? _productSubscription;

  ProductManagementCubit(this._productRepository, this._customerRepository, this._userRepository) : super(ProductManagementInitial());

  // 상품 목록 불러오기
  void loadProducts() async {
    emit(ProductManagementLoading());
    try {
      final users = await _userRepository.getAllUsers();
      final userMap = {for (var user in users) user.uid: user.name};

      _productSubscription?.cancel();
      _productSubscription = _productRepository.getProducts().listen((products) {
        // 상태가 생성될 때 데이터 가공이 이루어짐
        emit(ProductManagementLoaded(products, userMap));
      }, onError: (error) {
        emit(ProductManagementError(error.toString()));
      });
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  // 상품 추가
  Future<void> addProduct({
    required String name,
    required double price,
    required String type,
    required String size,
    required String gender,
    required int count,
  }) async {
    try {
      final userBox = Hive.box('user');
      final registeredByUid = userBox.get('uid') as String?;
      if (registeredByUid == null) {
        emit(const ProductManagementError('로그인 정보를 찾을 수 없습니다.'));
        return;
      }
      
      await _productRepository.addProduct(
        name: name,
        price: price,
        type: type,
        size: size,
        gender: gender,
        count: count,
        registeredBy: registeredByUid,
      );
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  // 상품 삭제 (UID 기반)
  Future<void> deleteProduct(String uid) async {
     try {
      await _productRepository.deleteProduct(uid);
    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  // 모든 고객 목록 가져오기
  Future<List<Customer>> getCustomers() async {
    return await _customerRepository.getAllCustomers();
  }

  // 대여 또는 판매 처리
  Future<void> processTransaction({
    required Product product,
    required Customer customer,
    required String transactionType, // "rent" or "sell"
  }) async {
    try {
      await _productRepository.processTransaction(
        product: product,
        customer: customer,
        transactionType: transactionType,
      );
      final message = transactionType == 'rent' ? '${product.name} 상품이 대여되었습니다.' : '${product.name} 상품이 판매되었습니다.';
      
      // 현재 상태가 Loaded일 때만 메시지와 함께 상태 갱신
      if (state is ProductManagementLoaded) {
        final currentState = state as ProductManagementLoaded;
        emit(currentState.copyWith(transactionMessage: message));
      }

    } catch (e) {
      emit(ProductManagementError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }
}
