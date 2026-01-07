import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String name;
  final String phoneNumber;

  AppUser({required this.uid, required this.name, required this.phoneNumber});

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '이름 없음',
      phoneNumber: data['phoneNumber'] ?? '번호 없음',
    );
  }
}
