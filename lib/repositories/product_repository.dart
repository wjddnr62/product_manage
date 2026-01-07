import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehabiltiation/models/customer_model.dart';
import 'package:rehabiltiation/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 모든 상품 목록 실시간 스트림
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('lastTransactionDate', descending: true) // 정렬 기준 변경
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  // 히스토리 페이지네이션용
  Future<List<DocumentSnapshot>> fetchHistoryProducts({DocumentSnapshot? lastDocument}) async {
    var query = _firestore
        .collection('products')
        .orderBy('lastTransactionDate', descending: true)
        .limit(20);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  // 상품 추가
  Future<void> addProduct({
    required String name,
    required double price,
    required String type,
    required String size,
    required String gender,
    required int count,
    required String registeredBy,
  }) async {
    final batch = _firestore.batch();
    final now = FieldValue.serverTimestamp();

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
        'registeredBy': registeredBy,
        'createdAt': now,
        'lastTransactionDate': now, // 필드 추가
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
  }) async {
    final productRef = _firestore.collection('products').doc(product.uid);
    final customerRef = _firestore.collection('customers').doc(customer.uid);

    return _firestore.runTransaction((transaction) async {
      final now = Timestamp.now();

      if (transactionType == 'rent') {
        final returnDate = now.toDate().add(const Duration(days: 3)); // 2일에서 3일로 변경
        transaction.update(productRef, {
          'status': 'rented',
          'rentedToUid': customer.uid,
          'rentedToName': customer.name,
          'rentedDate': now,
          'returnDate': Timestamp.fromDate(returnDate),
          'lastTransactionDate': now, // 필드 업데이트
        });
        transaction.update(customerRef, {
          'rentalCount': FieldValue.increment(1),
          'lastUsedDate': now,
          'lastUsedProduct': product.name,
          'rentedProducts': FieldValue.arrayUnion([{'productId': product.uid, 'productName': product.name, 'returnDate': Timestamp.fromDate(returnDate)}])
        });
      } else { // "sell"
        transaction.update(productRef, {
          'status': 'sold',
          'soldDate': now,
          'soldToUid': customer.uid,
          'soldToName': customer.name,
          'lastTransactionDate': now, // 필드 업데이트
        });
        transaction.update(customerRef, {
          'purchaseCount': FieldValue.increment(1),
          'lastUsedDate': now,
          'lastUsedProduct': product.name,
          'purchasedProducts': FieldValue.arrayUnion([{'productId': product.uid, 'productName': product.name, 'purchaseDate': now}])
        });
      }
    });
  }
}
