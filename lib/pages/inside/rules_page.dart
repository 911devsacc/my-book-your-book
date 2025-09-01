import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_book_your_book/main_screen.dart';

class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final studentId = user?.displayName ?? 'Rules';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          studentId,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel")),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MainScreen()),
                        );
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome! To ensure a safe and successful book exchange, please follow these rules:',
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 24),

              // Rule 1
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.green),
                          SizedBox(width: 8),
                          Text('1. Meet in Public Places',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'For your safety, always arrange to meet in well-lit, public locations on or near campus.',
                      ),
                    ],
                  ),
                ),
              ),

              // Rule 2
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.green),
                          SizedBox(width: 8),
                          Text('2. Agree on Time & Place',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Always confirm the exact time and location for the exchange with the other user before meeting.',
                      ),
                    ],
                  ),
                ),
              ),

              // Rule 3
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.security, color: Colors.green),
                          SizedBox(width: 8),
                          Text('3. Secure Your Account',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Never share your password or personal information with anyone.',
                      ),
                    ],
                  ),
                ),
              ),

              // Rule 4
              Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Row(
                        children: [
                          Icon(Icons.attach_money, color: Colors.green),
                          SizedBox(width: 8),
                          Text('4. Agree on Terms',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Confirm all exchange details, including payment or trade, before meeting to avoid any misunderstandings.',
                      ),
                    ],
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
