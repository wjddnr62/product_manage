import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/models/product_model.dart';
import 'package:rehabiltiation/repositories/customer_repository.dart';
import 'package:rehabiltiation/repositories/product_repository.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_cubit.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_state.dart';
import 'package:rehabiltiation/screens/product/widgets/add_product_dialog.dart';
import 'package:rehabiltiation/screens/product/widgets/process_transaction_dialog.dart';

class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductManagementCubit(ProductRepository(), CustomerRepository())..loadProducts(),
      child: const ProductManagementView(),
    );
  }
}

class ProductManagementView extends StatelessWidget {
  const ProductManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductManagementCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => showDialog(
              context: context,
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const AddProductDialog(),
              ),
            ),
            tooltip: '상품 추가',
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<ProductManagementCubit, ProductManagementState>(
          listener: (context, state) {
            if (state is ProductManagementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is ProductManagementInitial || state is ProductManagementLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProductManagementLoaded) {
              if (state.products.isEmpty) {
                return const Center(child: Text('상품을 추가해주세요'));
              }
              
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 80), 
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('${product.type} / ${product.gender} / ${product.size} / ${product.price.toStringAsFixed(0)}원'),
                    trailing: Chip(
                      label: Text(product.status == 'available' ? '재고있음' : (product.status == 'rented' ? '대여중' : '판매완료')),
                      backgroundColor: product.status == 'available' ? Colors.green : (product.status == 'rented' ? Colors.orange : Colors.grey),
                      labelStyle: const TextStyle(color: Colors.white),
                    ),
                    onTap: product.status == 'available' ? () {
                      showDialog(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: cubit,
                          child: ProcessTransactionDialog(product: product),
                        ),
                      );
                    } : null,
                  );
                },
              );
            }
            return const Center(child: Text('알 수 없는 오류가 발생했습니다.'));
          },
        ),
      ),
    );
  }
}
