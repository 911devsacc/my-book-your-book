import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_book_your_book/pages/inside/bottom_navigation.dart.dart';
import 'package:my_book_your_book/pages/auth/login_page.dart';
import 'package:my_book_your_book/pages/auth/signup_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showLogin = true; // toggle between login and signup

  // Inside _MainScreenState
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data!.emailVerified) {
          // ✅ User is logged in AND email is verified
          // You can add a loading screen here while fetching other user data
          return const BottomNavigation();
        }

        // 👤 User is not logged in or email is not verified
        return Scaffold(
          body: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _showLogin ? const LoginPage() : const SignupPage(),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showLogin = !_showLogin;
                    });
                  },
                  child: Text(
                    _showLogin
                        ? "Don’t have an account? Sign up"
                        : "Already have an account? Log in",
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
