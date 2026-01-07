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
  final String? transactionMessage;

  // UI 렌더링을 위한 가공된 데이터
  final List<ProductGroup> groupedAvailableProducts;

  ProductManagementLoaded(this.allProducts, this.userMap, {this.transactionMessage})
      : groupedAvailableProducts = _groupProducts(allProducts);

  // 데이터를 상태 클래스 내부에서 가공
  static List<ProductGroup> _groupProducts(List<Product> products) {
    final available = products.where((p) => p.status == 'available').toList();
    final Map<String, List<Product>> grouped = {};
    for (var product in available) {
      final key = product.name;
      if (grouped.containsKey(key)) {
        grouped[key]!.add(product);
      } else {
        grouped[key] = [product];
      }
    }
    return grouped.entries
        .map((entry) => ProductGroup(name: entry.key, products: entry.value))
        .toList();
  }

  ProductManagementLoaded copyWith({
    List<Product>? allProducts,
    Map<String, String>? userMap,
    String? transactionMessage,
  }) {
    return ProductManagementLoaded(
      allProducts ?? this.allProducts,
      userMap ?? this.userMap,
      transactionMessage: transactionMessage,
    );
  }

  @override
  List<Object?> get props => [allProducts, userMap, transactionMessage];
}

// UI에서 사용할 그룹 모델
class ProductGroup extends Equatable {
  final String name;
  final List<Product> products;
  final int stock;

  ProductGroup({required this.name, required this.products}) 
      : stock = products.length;

  @override
  List<Object?> get props => [name, products];
}

class ProductManagementError extends ProductManagementState {
  final String error;
  const ProductManagementError(this.error);
  @override
  List<Object?> get props => [error];
}
