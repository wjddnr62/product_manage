import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rehabiltiation/models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
  }
}
