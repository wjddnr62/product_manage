import 'package:flutter/foundation.dart';
import 'package:rehabiltiation/models/customer_model.dart';

@immutable
abstract class CustomerManagementState {
  const CustomerManagementState();
}

class CustomerManagementInitial extends CustomerManagementState {}

class CustomerManagementLoading extends CustomerManagementState {}

class CustomerManagementLoaded extends CustomerManagementState {
  final List<Customer> customers;
  const CustomerManagementLoaded(this.customers);
}

class CustomerManagementError extends CustomerManagementState {
  final String error;
  const CustomerManagementError(this.error);
}
