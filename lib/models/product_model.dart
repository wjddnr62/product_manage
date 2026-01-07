import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String uid;
  final String name;
  final double price;
  final String type; // 대여 or 판매
  final String size;
  final String gender; // 남성, 여성, 공용
  final DateTime createdAt;

  final String status; // "available", "rented", "sold"
  final String? rentedToUid;
  final String? rentedToName;
  final DateTime? rentedDate; 
  final DateTime? returnDate; 
  final DateTime? soldDate;
  final String? soldToUid;
  final String? soldToName;
  final String? registeredBy; 
  final DateTime? lastTransactionDate; // 상태 변경일 (정렬용)

  Product({
    required this.uid,
    required this.name,
    required this.price,
    required this.type,
    required this.size,
    required this.gender,
    required this.createdAt,
    this.status = 'available',
    this.rentedToUid,
    this.rentedToName,
    this.rentedDate,
    this.returnDate,
    this.soldDate,
    this.soldToUid,
    this.soldToName,
    this.registeredBy,
    this.lastTransactionDate,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '이름 없음',
      price: (data['price'] ?? 0).toDouble(),
      type: data['type'] ?? '-',
      size: data['size'] ?? '-',
      gender: data['gender'] ?? '-',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'available',
      rentedToUid: data['rentedToUid'] as String?,
      rentedToName: data['rentedToName'] as String?,
      rentedDate: (data['rentedDate'] as Timestamp?)?.toDate(),
      returnDate: (data['returnDate'] as Timestamp?)?.toDate(),
      soldDate: (data['soldDate'] as Timestamp?)?.toDate(),
      soldToUid: data['soldToUid'] as String?,
      soldToName: data['soldToName'] as String?,
      registeredBy: data['registeredBy'] as String?,
      lastTransactionDate: (data['lastTransactionDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'price': price,
      'type': type,
      'size': size,
      'gender': gender,
      'createdAt': createdAt,
      'status': status,
      'rentedToUid': rentedToUid,
      'rentedToName': rentedToName,
      'rentedDate': rentedDate,
      'returnDate': returnDate,
      'soldDate': soldDate,
      'soldToUid': soldToUid,
      'soldToName': soldToName,
      'registeredBy': registeredBy,
      'lastTransactionDate': lastTransactionDate,
    };
  }
}
