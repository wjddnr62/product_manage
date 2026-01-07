import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehabiltiation/models/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _firestore;

  CustomerRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // 고객 목록 실시간 스트림
  Stream<List<Customer>> getCustomers() {
    return _firestore.collection('customers').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
    });
  }

  // 모든 고객 목록 가져오기 (1회성)
  Future<List<Customer>> getAllCustomers() async {
    final snapshot = await _firestore.collection('customers').orderBy('name').get();
    return snapshot.docs.map((doc) => Customer.fromFirestore(doc)).toList();
  }

  // 전화번호로 고객 중복 확인
  Future<bool> isPhoneNumberDuplicate(String phoneNumber) async {
    final query = await _firestore.collection('customers').where('phoneNumber', isEqualTo: phoneNumber).limit(1).get();
    return query.docs.isNotEmpty;
  }

  // 고객 추가
  Future<void> addCustomer({
    required String name,
    required String phoneNumber,
    required String gender,
    int? age,
  }) async {
    final docRef = _firestore.collection('customers').doc();
    final newCustomer = {
      'uid': docRef.id,
      'name': name,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'rentalCount': 0, // 대여 횟수 초기화
      'purchaseCount': 0, // 구매 횟수 초기화
      'lastUsedDate': null, // 최근 이용일 초기화
      'lastUsedProduct': null, // 최근 이용 상품 초기화
      'createdAt': FieldValue.serverTimestamp(),
      'rentedProducts': [],
      'purchasedProducts': [],
    };
    await docRef.set(newCustomer);
  }
}
