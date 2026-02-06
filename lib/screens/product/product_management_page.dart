import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/models/product_model.dart';
import 'package:rehabiltiation/repositories/customer_repository.dart';
import 'package:rehabiltiation/repositories/product_repository.dart';
import 'package:rehabiltiation/repositories/user_repository.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_cubit.dart';
import 'package:rehabiltiation/screens/product/cubit/product_management_state.dart';
import 'package:rehabiltiation/screens/product/product_history_page.dart';
import 'package:rehabiltiation/screens/product/widgets/add_product_dialog.dart';
import 'package:rehabiltiation/screens/product/widgets/process_transaction_dialog.dart';
import 'package:rehabiltiation/widgets/data_driven_view.dart';
import 'package:rehabiltiation/widgets/reusable_expansion_tile_card.dart';

class ProductManagementPage extends StatelessWidget {
  const ProductManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductManagementCubit(
        ProductRepository(),
        CustomerRepository(),
        UserRepository(),
      )..loadProducts(),
      child: const ProductManagementView(),
    );
  }
}

class ProductManagementView extends StatefulWidget {
  const ProductManagementView({super.key});

  @override
  State<ProductManagementView> createState() => _ProductManagementViewState();
}

class _ProductManagementViewState extends State<ProductManagementView> {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProductManagementCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 재고 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductHistoryPage()),
            ),
            tooltip: '전체 히스토리 보기',
          ),
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
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                ),
              );
            } else if (state is ProductManagementLoaded &&
                state.transactionMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.transactionMessage!),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          builder: (context, state) {
            ViewState viewState = ViewState.loading;
            if (state is ProductManagementError) viewState = ViewState.error;
            if (state is ProductManagementLoaded) viewState = ViewState.success;

            return DataDrivenView<ProductManagementLoaded>(
              viewState: viewState,
              data: state is ProductManagementLoaded
                  ? state
                  : ProductManagementLoaded([], {}),
              onRetry: () => cubit.loadProducts(),
              successBuilder: (data) {
                if (data.groupedAvailableProducts.isEmpty) {
                  return const Center(child: Text('대여/판매 가능한 상품이 없습니다.'));
                }

                final currencyFormatter = NumberFormat('#,###');
                final formatter = DateFormat('yyyy-MM-dd HH:mm');

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: data.groupedAvailableProducts.length,
                  itemBuilder: (context, index) {
                    final group = data.groupedAvailableProducts[index];

                    return ReusableExpansionTileCard(
                      key: ValueKey(group.name),
                      pageStorageKey: group.name,
                      title: group.name,
                      subtitle: Text('재고: ${group.stock}'),
                      children: group.products.map((product) {
                        return Dismissible(
                          key: Key(product.uid),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            cubit.deleteProduct(product.uid);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${product.name} 상품을 삭제했습니다.'),
                              ),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              '${product.type} / ${product.gender} / ${product.size} / ${currencyFormatter.format(product.price)}원',
                            ),
                            subtitle: Text(
                              '등록일: ${formatter.format(product.createdAt.toLocal())}',
                            ),
                            onTap: () async {
                              try {
                                final customers = await cubit.getCustomers();
                                if (!context.mounted) return;

                                if (customers.isEmpty) {
                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('알림'),
                                      content: const Text(
                                        '선택할 수 있는 고객 정보가 없습니다.\n고객을 먼저 등록해주세요.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text('확인'),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (_) => BlocProvider.value(
                                      value: cubit,
                                      child: ProcessTransactionDialog(
                                        product: product,
                                        customers: customers,
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('고객 목록을 불러오는 중 오류가 발생했습니다.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
