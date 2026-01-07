import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rehabiltiation/models/product_model.dart';
import 'package:rehabiltiation/repositories/product_repository.dart';
import 'package:rehabiltiation/repositories/user_repository.dart';
import 'package:rehabiltiation/screens/product/cubit/product_history_state.dart';

class ProductHistoryCubit extends Cubit<ProductHistoryState> {
  final ProductRepository _productRepository;
  final UserRepository _userRepository;

  ProductHistoryCubit(this._productRepository, this._userRepository) : super(const ProductHistoryState());

  Future<void> fetchNextPage() async {
    if (state.hasReachedMax) return;

    try {
      // 첫 페이지 로드 시에만 사용자 정보 가져오기
      Map<String, String> userMap = state.userMap;
      if (state.products.isEmpty && state.userMap.isEmpty) {
        final users = await _userRepository.getAllUsers();
        userMap = {for (var user in users) user.uid: user.name};
      }

      final docs = await _productRepository.fetchHistoryProducts(lastDocument: state.lastDocument);
      if (docs.isEmpty) {
        emit(state.copyWith(hasReachedMax: true, userMap: userMap));
      } else {
        final products = docs.map((doc) => Product.fromFirestore(doc)).toList();
        emit(state.copyWith(
          products: List.of(state.products)..addAll(products),
          lastDocument: docs.last,
          hasReachedMax: false,
          userMap: userMap,
        ));
      }
    } catch (e) {
      // 에러 처리 (필요 시)
    }
  }
}
