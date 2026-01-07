import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehabiltiation/models/product_model.dart';
import 'package:rehabiltiation/models/customer_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 상품 목록 실시간 스트림
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // 상품 추가
  Future<void> addProduct({
    required String name,
    required double price,
    required String type,
    required String size,
    required String gender,
    required int count,
  }) async {
    final batch = _firestore.batch();

    for (int i = 0; i < count; i++) {
      final docRef = _firestore.collection('products').doc();
      final newProduct = {
        'uid': docRef.id,
        'name': name,
        'price': price,
        'type': type,
        'size': size,
        'gender': gender,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      };
      batch.set(docRef, newProduct);
    }

    await batch.commit();
  }

  // 상품 삭제 (UID 기반)
  Future<void> deleteProduct(String uid) async {
    await _firestore.collection('products').doc(uid).delete();
  }

  // 대여 또는 판매 처리
  Future<void> processTransaction({
    required Product product,
    required Customer customer,
    required String transactionType, // "rent" or "sell"
    DateTime? returnDate,
  }) async {
    final productRef = _firestore.collection('products').doc(product.uid);
    final customerRef = _firestore.collection('customers').doc(customer.uid);

    return _firestore.runTransaction((transaction) async {
      // 1. 상품 상태 업데이트
      if (transactionType == 'rent') {
        transaction.update(productRef, {
          'status': 'rented',
          'rentedToUid': customer.uid,
          'rentedToName': customer.name,
          'returnDate': returnDate,
        });
        // 2. 고객 정보 업데이트 (대여)
        transaction.update(customerRef, {
          'rentalCount': FieldValue.increment(1),
          'lastUsedDate': FieldValue.serverTimestamp(),
          'lastUsedProduct': product.name,
          'rentedProducts': FieldValue.arrayUnion([{'productId': product.uid, 'productName': product.name, 'returnDate': returnDate}])
        });
      } else { // "sell"
        transaction.update(productRef, {'status': 'sold'});
        // 2. 고객 정보 업데이트 (판매)
        transaction.update(customerRef, {
          'purchaseCount': FieldValue.increment(1),
          'lastUsedDate': FieldValue.serverTimestamp(),
          'lastUsedProduct': product.name,
          'purchasedProducts': FieldValue.arrayUnion([{'productId': product.uid, 'productName': product.name, 'purchaseDate': FieldValue.serverTimestamp()}])
        });
      }
    });
  }
}
