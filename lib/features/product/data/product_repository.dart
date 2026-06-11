import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/product_model.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProducts() async {
    final snapshot = await _firestore.collection('products').get();

    return snapshot.docs.map((doc) {
      return Product.fromMap(doc.id, doc.data());
    }).toList();
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();

    if (!doc.exists) return null;

    return Product.fromMap(doc.id, doc.data()!);
  }
}
