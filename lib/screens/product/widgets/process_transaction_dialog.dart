import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/models/product_model.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_cubit.dart';

class ProcessTransactionDialog extends StatefulWidget {
  const ProcessTransactionDialog({super.key, required this.product});

  final Product product;

  @override
  State<ProcessTransactionDialog> createState() => _ProcessTransactionDialogState();
}

class _ProcessTransactionDialogState extends State<ProcessTransactionDialog> {
  Customer? _selectedCustomer;
  DateTime? _returnDate;

  Future<void> _selectReturnDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _returnDate) {
      setState(() {
        _returnDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.product.name} 처리'),
      content: FutureBuilder<List<Customer>>(
        future: context.read<ProductManagementCubit>().getCustomers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final customers = snapshot.data!;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<Customer>(
                  value: _selectedCustomer,
                  hint: const Text('고객 선택'),
                  items: customers.map((customer) {
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
                if (widget.product.type == '대여')
                  ListTile(
                    title: Text(_returnDate == null ? '반납일 선택' : '반납일: ${_returnDate!.toLocal().toString().split(' ')[0]}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () => _selectReturnDate(context),
                  ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text('취소'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          child: Text(widget.product.type == '대여' ? '대여 처리' : '판매 처리'),
          onPressed: () {
            if (_selectedCustomer == null) return;
            if (widget.product.type == '대여' && _returnDate == null) return;

            context.read<ProductManagementCubit>().processTransaction(
                  product: widget.product,
                  customer: _selectedCustomer!,
                  transactionType: widget.product.type == '대여' ? 'rent' : 'sell',
                  returnDate: _returnDate,
                );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
