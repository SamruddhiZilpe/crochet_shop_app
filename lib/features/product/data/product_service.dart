import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct({
    required String id,
    required String name,
    required int price,
    required String category,
    required String imageUrl,
  }) async {
    await _firestore.collection('products').doc(id).set({
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image': imageUrl,
    });
  }
}