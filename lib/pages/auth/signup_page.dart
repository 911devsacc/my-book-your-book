import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_book_your_book/main_screen.dart';
import 'package:my_book_your_book/widgets/custom_textfield.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _signup() async {
  if (!_formKey.currentState!.validate()) return;

  try {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      String studentId = email.split('@')[0];
      await user.updateDisplayName(studentId);

      await user.sendEmailVerification();
      
      // POP-UP DIALOG IS NOW SHOWN FIRST
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.green[50],
          title: const Text(
            'Verification Email Sent!',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'A verification email has been sent. Please verify your email before logging in.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () async { // NOTE: NOW ASYNC
                Navigator.of(ctx).pop(); // close dialog
                await FirebaseAuth.instance.signOut(); // SIGNOUT IS NOW HERE
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainScreen()),
                );
              },
              child: const Text('OK', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );
    }
  } on FirebaseAuthException catch (e) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'This email is already registered.';
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
                'MY BOOK YOUR BOOK!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
              const SizedBox(height: 12),
              CustomTextField(
                controller: _confirmPasswordController,
                labelText: 'Confirm Password',
                isPassword: true,
                validator: (value) {
                  if (value != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _signup,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 18, 167, 4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      'Sign Up',
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
