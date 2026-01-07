import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_cubit.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _countController = TextEditingController(text: '1');
  final _sizeController = TextEditingController();
  String? _selectedType;
  String? _selectedGender = '공용'; // 기본값 '공용'으로 설정
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _countController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('상품 추가'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '상품명'),
                textInputAction: TextInputAction.next, 
                validator: (v) => (v?.trim().isEmpty ?? true) ? '상품명을 입력해주세요.' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: '가격',
                  suffixText: '원',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next, 
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v?.trim().isEmpty ?? true) ? '가격을 입력해주세요.' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedType,
                hint: const Text('판매/대여 여부'),
                items: ['대여', '판매'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? '타입을 선택해주세요.' : null,
              ),
              TextFormField(
                controller: _countController,
                decoration: const InputDecoration(labelText: '상품 갯수'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return '갯수를 입력해주세요.';
                  if (int.tryParse(v) == null || int.parse(v) < 1) return '1 이상의 숫자를 입력해주세요.';
                  return null;
                },
              ),
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: '사이즈'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (v?.trim().isEmpty ?? true) ? '사이즈를 입력해주세요.' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: const Text('성별 선택'),
                items: ['남성', '여성', '공용'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                onChanged: (v) => setState(() => _selectedGender = v),
                validator: (v) => v == null ? '성별을 선택해주세요.' : null,
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

            setState(() { _isLoading = true; });

            await context.read<ProductManagementCubit>().addProduct(
                  name: _nameController.text,
                  price: double.parse(_priceController.text),
                  type: _selectedType!,
                  size: _sizeController.text,
                  gender: _selectedGender!,
                  count: int.parse(_countController.text),
                );

            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${_nameController.text} 상품 ${_countController.text}개를 추가했습니다.')),
              );
            }
          },
          child: _isLoading ? const SizedBox(height: 15, width: 15, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('저장'),
        ),
      ],
    );
  }
}
