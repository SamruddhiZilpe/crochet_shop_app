import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/user_profile_model.dart';

class ProfileRepository {
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _auth = FirebaseAuth.instance;

  String get uid => _auth.currentUser!.uid;

  Future<UserProfileModel> getProfile() async {
    final doc = await _firestore.collection('users').doc(uid).get();

    return UserProfileModel.fromMap(doc.data() ?? {});
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
    }, SetOptions(merge: true));
  }

  Future<String> uploadImage(File file) async {
    final ref = _storage.ref().child('profile_images/$uid.jpg');

    await ref.putFile(file);

    final url = await ref.getDownloadURL();

    await _firestore.collection('users').doc(uid).set({
      'imageUrl': url,
    }, SetOptions(merge: true));

    return url;
  }
}
