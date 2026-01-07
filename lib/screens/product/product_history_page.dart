import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rehabiltiation/repositories/product_repository.dart';
import 'package:rehabiltiation/repositories/user_repository.dart';
import 'package:rehabiltiation/screens/product/cubit/product_history_cubit.dart';
import 'package:rehabiltiation/screens/product/cubit/product_history_state.dart';
import 'package:rehabiltiation/screens/product/widgets/product_history_detail_dialog.dart';

class ProductHistoryPage extends StatelessWidget {
  const ProductHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductHistoryCubit(ProductRepository(), UserRepository())..fetchNextPage(),
      child: const ProductHistoryView(),
    );
  }
}

class ProductHistoryView extends StatefulWidget {
  const ProductHistoryView({super.key});

  @override
  State<ProductHistoryView> createState() => _ProductHistoryViewState();
}

class _ProductHistoryViewState extends State<ProductHistoryView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<ProductHistoryCubit>().fetchNextPage();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('상품 전체 히스토리'),
      ),
      body: SafeArea(
        child: BlocBuilder<ProductHistoryCubit, ProductHistoryState>(
          builder: (context, state) {
            if (state.products.isEmpty && state.hasReachedMax) {
              return const Center(child: Text('상품 내역이 없습니다.'));
            } 
            if (state.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: state.hasReachedMax ? state.products.length : state.products.length + 1,
              itemBuilder: (context, index) {
                if (index >= state.products.length) {
                  return const Center(child: CircularProgressIndicator());
                }

                final product = state.products[index];
                final formatter = DateFormat('yyyy-MM-dd');
                final currencyFormatter = NumberFormat('#,###');

                 String dateInfoText = '';
                  if (product.status == 'available') {
                    dateInfoText = '등록일: ${formatter.format(product.createdAt.toLocal())}';
                  } else if (product.status == 'sold') {
                    dateInfoText = '판매일: ${product.soldDate != null ? formatter.format(product.soldDate!.toLocal()) : '-'}';
                  } else if (product.status == 'rented') {
                    final returnDate = product.returnDate;
                    if (returnDate != null) {
                      final isOverdue = returnDate.isBefore(DateTime.now());
                      if (isOverdue) {
                        final overdueDays = DateTime.now().difference(returnDate).inDays;
                        final overdueFee = overdueDays * 10000;
                        dateInfoText = '반납 예정일: ${formatter.format(returnDate.toLocal())} (연체 ${overdueDays}일 / ${currencyFormatter.format(overdueFee)}원)';
                      } else {
                        dateInfoText = '반납 예정일: ${formatter.format(returnDate.toLocal())}';
                      }
                    } else {
                      dateInfoText = '반납 예정일: 정보 없음';
                    }
                  }

                  Widget? trailingWidget;
                  if (product.status == 'rented') {
                    trailingWidget = Text('대여자: ${product.rentedToName ?? '-'}');
                  } else if (product.status == 'sold') {
                    trailingWidget = Text('구매자: ${product.soldToName ?? '-'}');
                  } else { 
                    final registeredByName = context.read<ProductHistoryCubit>().state.userMap[product.registeredBy] ?? '알 수 없음';
                    trailingWidget = Text('등록자: $registeredByName');
                  }

                return ListTile(
                  title: Text(product.name),
                  subtitle: Text(dateInfoText),
                  trailing: trailingWidget,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => ProductHistoryDetailDialog(
                        product: product,
                        userMap: context.read<ProductHistoryCubit>().state.userMap,
                      ),
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
