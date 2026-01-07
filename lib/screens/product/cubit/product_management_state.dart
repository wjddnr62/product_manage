import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:rehabiltiation/models/product_model.dart';

@immutable
abstract class ProductManagementState extends Equatable {
  const ProductManagementState();
  @override
  List<Object?> get props => [];
}

class ProductManagementInitial extends ProductManagementState {}

class ProductManagementLoading extends ProductManagementState {}

class ProductManagementLoaded extends ProductManagementState {
  final List<Product> allProducts;
  final Map<String, String> userMap;
  final String? transactionMessage; // 성공 메시지

  const ProductManagementLoaded(this.allProducts, this.userMap, {this.transactionMessage});

  ProductManagementLoaded copyWith({
    List<Product>? allProducts,
    Map<String, String>? userMap,
    String? transactionMessage,
  }) {
    return ProductManagementLoaded(
      allProducts ?? this.allProducts,
      userMap ?? this.userMap,
      transactionMessage: transactionMessage, // 메시지는 복사하지 않고 새로 받음
    );
  }

  @override
  List<Object?> get props => [allProducts, userMap, transactionMessage];
}

class ProductManagementError extends ProductManagementState {
  final String error;
  const ProductManagementError(this.error);
   @override
  List<Object?> get props => [error];
}

// 이 상태는 더 이상 사용하지 않음
// class TransactionSuccess extends ProductManagementState {
//   final String message;
//   const TransactionSuccess(this.message);
// }
