import 'package:first_project/features/profile/presentation/pages/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String name = "Samruddhi Zilpe";
  String email = "samruddhi@example.com";

  final String imageUrl =
      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQv7rFiM9IdHxVdI2UvYd3OCsPIzW9qm2U0PfCbG3SlJJqha_neA8Lp0Ww&s";

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
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
              backgroundImage: NetworkImage(imageUrl),
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
            Text(
              email,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),

            /// EDIT PROFILE
            ProfileMenuTile(
              icon: Icons.edit,
              title: "Edit Profile",
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(
                      name: name,
                      email: email,
                    ),
                  ),
                );

                if (result != null) {
                  setState(() {
                    name = result["name"];
                    email = result["email"];
                  });
                }
              },
            ),

            /// ORDERS
            ProfileMenuTile(
              icon: Icons.shopping_bag,
              title: "My Orders",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrdersScreen(),
                  ),
                );
              },
            ),

            /// WISHLIST
            ProfileMenuTile(
              icon: Icons.favorite,
              title: "Wishlist",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WishlistScreen(),
                  ),
                );
              },
            ),

            /// SETTINGS
            ProfileMenuTile(
              icon: Icons.settings,
              title: "Settings",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),

            /// LOGOUT
            ProfileMenuTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool('isLoggedIn', false);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AuthScreen(),
                  ),
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