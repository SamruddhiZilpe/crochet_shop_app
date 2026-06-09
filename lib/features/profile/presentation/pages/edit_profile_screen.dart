import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  final String name;
  final String email;

  const EditProfileScreen({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    // Use values coming from ProfileScreen
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQv7rFiM9IdHxVdI2UvYd3OCsPIzW9qm2U0PfCbG3SlJJqha_neA8Lp0Ww&s",
              ),
            ),

            const SizedBox(height: 30),

            // NAME
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.cardColor,
              ),
            ),

            const SizedBox(height: 16),

            // EMAIL
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: theme.cardColor,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: "Save Changes",
                width: double.infinity,
                height: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                onPressed: () {
                  Navigator.pop(context, {
                    "name": nameController.text,
                    "email": emailController.text,
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}