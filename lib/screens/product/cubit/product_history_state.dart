import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:rehabiltiation/models/product_model.dart';

class ProductHistoryState extends Equatable {
  final List<Product> products;
  final bool hasReachedMax;
  final DocumentSnapshot? lastDocument;
  final Map<String, String> userMap;

  const ProductHistoryState({
    this.products = const [],
    this.hasReachedMax = false,
    this.lastDocument,
    this.userMap = const {},
  });

  ProductHistoryState copyWith({
    List<Product>? products,
    bool? hasReachedMax,
    DocumentSnapshot? lastDocument,
    Map<String, String>? userMap,
    bool setLastDocumentToNull = false, // lastDocument를 명시적으로 null로 설정하기 위한 플래그
  }) {
    return ProductHistoryState(
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      lastDocument: setLastDocumentToNull ? null : lastDocument ?? this.lastDocument,
      userMap: userMap ?? this.userMap,
    );
  }

  @override
  List<Object?> get props => [products, hasReachedMax, lastDocument, userMap];
}
