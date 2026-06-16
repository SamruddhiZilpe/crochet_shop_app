import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadImage(File file, String productId) async {
    final ref = _storage.ref().child('products/$productId.jpg');

    await ref.putFile(file);

    return await ref.getDownloadURL();
  }
}