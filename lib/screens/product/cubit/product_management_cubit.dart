import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/models/product_model.dart';
import 'package:rehabiltiation/repositories/customer_repository.dart';
import 'package:rehabiltiation/repositories/product_repository.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_state.dart';

class ProductManagementCubit extends Cubit<ProductManagementState> {
  final ProductRepository _productRepository;
  final CustomerRepository _customerRepository;
  StreamSubscription? _productSubscription;

  ProductManagementCubit(this._productRepository, this._customerRepository) : super(ProductManagementInitial());

  // 상품 목록 불러오기
  void loadProducts() {
    emit(ProductManagementLoading());
    _productSubscription?.cancel();
    _productSubscription = _productRepository.getProducts().listen((products) {
      emit(ProductManagementLoaded(products));
    }, onError: (error) {
      emit(ProductManagementError(error.toString()));
    });
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
      await _productRepository.addProduct(
        name: name,
        price: price,
        type: type,
        size: size,
        gender: gender,
        count: count,
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
    DateTime? returnDate,
  }) async {
    try {
      await _productRepository.processTransaction(
        product: product,
        customer: customer,
        transactionType: transactionType,
        returnDate: returnDate,
      );
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
