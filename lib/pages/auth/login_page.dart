import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_book_your_book/pages/auth/validators.dart';
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
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
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
        await _showDialog(
          title: 'Account Not Verified',
          content:
              'Your email is not verified. Please check your email for a verification link.',
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resendVerificationEmail(user);
              },
              child: const Text('Resend link'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
        await FirebaseAuth.instance.signOut();
        return;
      }

    } on FirebaseAuthException catch (e) {
      _showSnackBar(_mapFirebaseError(e));
    } catch (_) {
      _showSnackBar('Something went wrong. Try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _resendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
      _showSnackBar('Verification email sent!');
    } catch (_) {
      _showSnackBar('Failed to send verification email.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      default:
        return 'An error occurred. Try again.';
    }
  }

  Future<void> _showDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.asset('assets/app-logo.png', width: 250),
            const SizedBox(height: 12),
            const Text(
              'Welcome back!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              validator: Validators.email,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              isPassword: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: Validators.password,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : GestureDetector(
                    onTap: _login,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
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
    );
  }
}
