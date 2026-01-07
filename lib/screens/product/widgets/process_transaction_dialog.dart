import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/models/product_model.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_cubit.dart';

class ProcessTransactionDialog extends StatefulWidget {
  const ProcessTransactionDialog({
    super.key,
    required this.product,
    required this.customers,
  });

  final Product product;
  final List<Customer> customers;

  @override
  State<ProcessTransactionDialog> createState() => _ProcessTransactionDialogState();
}

class _ProcessTransactionDialogState extends State<ProcessTransactionDialog> {
  Customer? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    if (widget.customers.length == 1) {
      _selectedCustomer = widget.customers.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('상품 처리'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<Customer>(
              value: _selectedCustomer, // initialValue를 value로 변경
              hint: const Text('고객 선택'),
              items: widget.customers.map((customer) {
                return DropdownMenuItem<Customer>(
                  value: customer,
                  child: Text(customer.name),
                );
              }).toList(),
              onChanged: (customer) {
                setState(() {
                  _selectedCustomer = customer;
                });
              },
              validator: (value) => value == null ? '고객을 선택해주세요.' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('취소'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.product.type == '대여' ? '대여 처리' : '판매 처리'),
          onPressed: () {
            if (_selectedCustomer == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('고객을 먼저 선택해주세요.')),
                );
                return;
            }
            
            context.read<ProductManagementCubit>().processTransaction(
                  product: widget.product,
                  customer: _selectedCustomer!,
                  transactionType: widget.product.type == '대여' ? 'rent' : 'sell',
                );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
