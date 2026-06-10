import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_dialog.dart';
import '../../navigation/presentation/main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // TITLE
              Text(
                isLogin ? "Login" : "Sign Up",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // EMAIL
              TextField(
                controller: emailController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "Email",
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // PASSWORD
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: "Password",
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // BUTTON
              CustomButton(
                text: isLogin ? "Login" : "Create Account",
                backgroundColor: Theme.of(context).colorScheme.primary,
                width: size.width * 0.8,
                height: size.height * 0.06,
                onPressed: () async {
                  try {
                    if (isLogin) {
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                    } else {
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                    }

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainNavigationScreen(),
                      ),
                          (route) => false,
                    );
                  } on FirebaseAuthException catch (e) {
                    String message = "Authentication failed";

                    if (e.code == 'invalid-credential') {
                      message =
                      "No account found with this email.\nPlease create an account first.";

                      await CustomDialog.show(
                        context: context,
                        title: "Account Not Found",
                        message: message,
                        buttonText: "Sign Up",
                        onPressed: () {
                          setState(() {
                            isLogin = false;
                          });
                        },
                      );

                      return;
                    }

                    if (e.code == 'email-already-in-use') {
                      message = "This email is already registered.";
                    }

                    if (e.code == 'weak-password') {
                      message = "Password must be at least 6 characters.";
                    }

                    await CustomDialog.show(
                      context: context,
                      title: "Authentication Error",
                      message: message,
                    );
                  }
                },
              ),

              const SizedBox(height: 15),

              // SWITCH LOGIN/SIGNUP
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(
                  isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Login",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}