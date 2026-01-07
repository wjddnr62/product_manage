import 'package:cloud_firestore/cloud_firestore.dart';

class Customer {
  final String uid;
  final String name;
  final int? age;
  final String gender;
  final String phoneNumber;
  final String? registeredBy; // 등록한 관리자 uid
  final int rentalCount;
  final int purchaseCount;
  final DateTime? lastUsedDate;
  final String? lastUsedProduct;
  final DateTime createdAt;
  final List<Map<String, dynamic>> rentedProducts;
  final List<Map<String, dynamic>> purchasedProducts;

  Customer({
    required this.uid,
    required this.name,
    this.age,
    required this.gender,
    required this.phoneNumber,
    this.registeredBy,
    required this.rentalCount,
    required this.purchaseCount,
    this.lastUsedDate,
    this.lastUsedProduct,
    required this.createdAt,
    this.rentedProducts = const [],
    this.purchasedProducts = const [],
  });

  factory Customer.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Customer(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '이름 없음',
      age: data['age'] as int?,
      gender: data['gender'] ?? '-',
      phoneNumber: data['phoneNumber'] ?? '번호 없음',
      registeredBy: data['registeredBy'] as String?,
      rentalCount: data['rentalCount'] ?? 0,
      purchaseCount: data['purchaseCount'] ?? 0,
      lastUsedDate: (data['lastUsedDate'] as Timestamp?)?.toDate(),
      lastUsedProduct: data['lastUsedProduct'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      rentedProducts: List<Map<String, dynamic>>.from(data['rentedProducts'] ?? []),
      purchasedProducts: List<Map<String, dynamic>>.from(data['purchasedProducts'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'registeredBy': registeredBy,
      'rentalCount': rentalCount,
      'purchaseCount': purchaseCount,
      'lastUsedDate': lastUsedDate,
      'lastUsedProduct': lastUsedProduct,
      'createdAt': createdAt,
      'rentedProducts': rentedProducts,
      'purchasedProducts': purchasedProducts,
    };
  }
}
