import 'package:my_book_your_book/pages/auth/validators.dart';
import 'package:my_book_your_book/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? selectedGender; // "male" or "female"

  // Local asset paths
  final String maleProfileAsset = "assets/images/male_pfp.png";
  final String femaleProfileAsset = "assets/images/female_pfp.png";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedGender == null) {
      _showSnackBar('Please select your gender.');
      return;
    }

    setState(() => _isLoading = true);

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

        final profilePicAsset =
            selectedGender == 'male' ? maleProfileAsset : femaleProfileAsset;

        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'studentId': studentId,
          'gender': selectedGender,
          'profilePic': profilePicAsset,
          'createdAt': FieldValue.serverTimestamp(),
        });

        await _showDialog(
          title: 'Verification Email Sent!',
          content:
              'Please verify your email before logging in. Check your inbox.',
          onOk: () async {
            Navigator.of(context).pop();
            await FirebaseAuth.instance.signOut();
          },
        );
      }
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.code == 'email-already-in-use'
          ? 'This email is already registered.'
          : 'An error occurred. Try again.');
    } catch (_) {
      _showSnackBar('Something went wrong. Try again.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showDialog({
    required String title,
    required String content,
    required VoidCallback onOk,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.green[50],
        title: Text(
          title,
          style: const TextStyle(
              color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: onOk,
            child: const Text('OK', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              'My Book Your Book!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            const SizedBox(height: 24),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              validator: Validators.email,
              showDomainButton: true,
              onDomainPressed: () {
                final currentText = _emailController.text.trim();
                if (!currentText.endsWith('@st.aabu.edu.jo')) {
                  _emailController.text = '$currentText@st.aabu.edu.jo';
                  _emailController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _emailController.text.length),
                  );
                }
              },
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
            const SizedBox(height: 12),
            CustomTextField(
              controller: _confirmController,
              labelText: 'Confirm Password',
              isPassword: _obscureConfirm,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              validator: (v) =>
                  Validators.confirmPassword(v, _passwordController.text),
            ),
            const SizedBox(height: 24),

            // ---------------- GENDER SELECTION ----------------
            const Text(
              "This can't be changed later!",
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Male'),
                  selected: selectedGender == 'male',
                  onSelected: (_) => setState(() => selectedGender = 'male'),
                  selectedColor: Colors.green[300],
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Female'),
                  selected: selectedGender == 'female',
                  onSelected: (_) => setState(() => selectedGender = 'female'),
                  selectedColor: Colors.green[300],
                ),
              ],
            ),
            const SizedBox(height: 24),

            _isLoading
                ? const CircularProgressIndicator()
                : GestureDetector(
                    onTap: _signup,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
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
    );
  }
}
