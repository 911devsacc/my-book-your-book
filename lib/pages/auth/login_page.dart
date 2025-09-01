import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_book_your_book/widgets/custom_textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();

        // New pop-up dialog with resend button
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Account Not Verified'),
            content: const Text(
              'Your email address has not been verified. Please check your email for a verification link.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                  _resendVerificationEmail(); // Call the resend function
                },
                child: const Text('Resend link'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      print('User logged in: ${user?.uid}');
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided.';
          break;
        default:
          message = 'An error occurred. Try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong.')),
      );
    }
  }
  
  // New function to resend the verification email
  Future<void> _resendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new verification email has been sent!'),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send verification email. Try again later.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.asset('assets/app-logo.png', width: 250),
              const SizedBox(height: 8),
              const Text(
                'Welcome back!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  if (!value.endsWith('@st.aabu.edu.jo')) return 'Use university email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter password';
                  if (value.length < 6) return 'Min 6 chars';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _login,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 18, 167, 4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
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
