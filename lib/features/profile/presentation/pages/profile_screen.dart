import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:veemadeforyou/features/profile/presentation/pages/settings_screen.dart';
import '../../../../shared/widgets/confirm_dialog.dart';
import '../../../../shared/widgets/profile_menu_tile.dart';
import '../../../auth/presentation/auth_screen.dart';
import '../../../order/presentation/pages/orders_screen.dart';
import '../../../wishlist/presentation/pages/wishlist_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  String? imageUrl;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data();

      setState(() {
        name = data?['name'] ?? "";
        email = data?['email'] ?? "";
        imageUrl = data?['imageUrl'];
      });
    } catch (e) {
      debugPrint("Load profile error: $e");
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      File file = File(pickedFile.path);

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$uid.jpg');

      await ref.putFile(file);

      final downloadUrl = await ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'imageUrl': downloadUrl,
      }, SetOptions(merge: true));

      setState(() {
        imageUrl = downloadUrl;
      });
    } catch (e) {
      debugPrint("Upload failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// PROFILE IMAGE
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: imageUrl == null
                      ? Icon(Icons.person, size: 50, color: theme.primaryColor)
                      : null,
                ),

                GestureDetector(
                  onTap: pickAndUploadImage,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: theme.primaryColor,
                    child: const Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// NAME
            Text(
              name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            /// EMAIL
            Text(email, style: theme.textTheme.bodyMedium),

            const SizedBox(height: 30),

            /// EDIT PROFILE
            ProfileMenuTile(
              icon: Icons.edit,
              title: "Edit Profile",
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(name: name, email: email),
                  ),
                );

                if (result == null) return;

                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(uid)
                      .set({
                        'name': result["name"],
                        'email': result["email"],
                      }, SetOptions(merge: true));

                  setState(() {
                    name = result["name"];
                    email = result["email"];
                  });
                } catch (e) {
                  debugPrint("Update profile error: $e");
                }
              },
            ),

            ProfileMenuTile(
              icon: Icons.shopping_bag,
              title: "My Orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersScreen()),
                );
              },
            ),

            ProfileMenuTile(
              icon: Icons.favorite,
              title: "Wishlist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WishlistScreen()),
                );
              },
            ),

            ProfileMenuTile(
              icon: Icons.settings,
              title: "Settings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),

            ProfileMenuTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: () async {
                final shouldLogout = await ConfirmDialog.show(
                  context: context,
                  title: "Logout",
                  message: "Are you sure you want to logout?",
                  confirmText: "Logout",
                  icon: Icons.logout,
                );

                if (!shouldLogout) return;

                await FirebaseAuth.instance.signOut();

                if (!mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
