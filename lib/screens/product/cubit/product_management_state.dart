import 'package:flutter/foundation.dart';
import 'package:rehabiltiation/models/product_model.dart';

@immutable
abstract class ProductManagementState {
  const ProductManagementState();
}

class ProductManagementInitial extends ProductManagementState {}

class ProductManagementLoading extends ProductManagementState {}

class ProductManagementLoaded extends ProductManagementState {
  final List<Product> products;
  const ProductManagementLoaded(this.products);
}

class ProductManagementError extends ProductManagementState {
  final String error;
  const ProductManagementError(this.error);
}
