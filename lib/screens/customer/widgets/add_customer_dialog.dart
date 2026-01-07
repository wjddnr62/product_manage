import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/screens/customer/cubit/customer_management_cubit.dart';
import 'package:rehabiltiation/screens/customer/cubit/customer_management_state.dart';

class AddCustomerDialog extends StatefulWidget {
  const AddCustomerDialog({super.key});

  @override
  State<AddCustomerDialog> createState() => _AddCustomerDialogState();
}

class _AddCustomerDialogState extends State<AddCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('고객 추가'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '이름'),
                validator: (value) => (value?.trim().isEmpty ?? true) ? '이름을 입력해주세요.' : null,
              ),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: '나이 (선택)'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 16),
              const Text('성별', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(child: RadioListTile<String>(title: const Text('남성'), value: '남성', groupValue: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v))),
                  Expanded(child: RadioListTile<String>(title: const Text('여성'), value: '여성', groupValue: _selectedGender, onChanged: (v) => setState(() => _selectedGender = v))),
                ],
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: '휴대폰 번호'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '휴대폰 번호를 입력해주세요.';
                  }
                  final phoneRegex = RegExp(r'^010[0-9]{8}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return '올바른 휴대폰 번호 형식이 아닙니다.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('취소'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (!_formKey.currentState!.validate()) return;
            if (_selectedGender == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('성별을 선택해주세요.')));
              return;
            }

            setState(() { _isLoading = true; });

            await context.read<CustomerManagementCubit>().addCustomer(
              name: _nameController.text,
              phoneNumber: _phoneController.text,
              gender: _selectedGender!,
              age: int.tryParse(_ageController.text),
            );

            if (mounted) {
              final state = context.read<CustomerManagementCubit>().state;
              if (state is! CustomerManagementError) {
                Navigator.of(context).pop();
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${_nameController.text} 님을 고객으로 추가했습니다.')));
              } else {
                 setState(() { _isLoading = false; });
              }
            }
          },
          child: _isLoading ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('저장'),
        ),
      ],
    );
  }
}
