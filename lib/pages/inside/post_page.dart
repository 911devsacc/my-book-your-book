import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostPage extends StatefulWidget {
  final VoidCallback? onPostPublished;

  const PostPage({super.key, this.onPostPublished});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController bookNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController exchangeForController = TextEditingController();

  String? selectedDepartment;
  String exchangeType = "free";

  final List<String> departments = [
    "Computer Science",
    "Software Engineering",
    "Information Technology",
    "Electrical Engineering",
    "Mechanical Engineering",
    "Civil Engineering",
    "Business Administration",
    "Accounting",
    "Law",
    "Medicine",
    "Nursing",
    "Pharmacy",
  ];

  Future<void> publishPost() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser!;
    final studentID = user.email!.split("@")[0];

    await FirebaseFirestore.instance.collection('posts').add({
      "ownerId": user.uid,
      "studentID": studentID,
      "bookName": bookNameController.text.trim(),
      "description": descriptionController.text.trim(),
      "exchangeType": exchangeType,
      "exchangeFor": exchangeType == "exchange"
          ? exchangeForController.text.trim()
          : null,
      "department": selectedDepartment,
      "createdAt": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Post Published ✅")),
    );

    if (widget.onPostPublished != null) {
      widget.onPostPublished!();
    }

    bookNameController.clear();
    descriptionController.clear();
    exchangeForController.clear();
    setState(() {
      selectedDepartment = null;
      exchangeType = "free";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Publish New Book!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: bookNameController,
                decoration: const InputDecoration(
                  labelText: "Book Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter book name" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: descriptionController,
                maxLength: 200,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? "Enter description"
                    : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Department",
                  border: OutlineInputBorder(),
                ),
                value: selectedDepartment,
                items: departments.map((dept) {
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(dept),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Select a department" : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("For Free"),
                      value: "free",
                      groupValue: exchangeType,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          exchangeType = value!;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("In Exchange"),
                      value: "exchange",
                      groupValue: exchangeType,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() {
                          exchangeType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              if (exchangeType == "exchange") ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: exchangeForController,
                  decoration: const InputDecoration(
                    labelText: "Exchange For",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (exchangeType == "exchange" &&
                        (value == null || value.isEmpty)) {
                      return "Specify what you want in exchange";
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: publishPost,
                child: const Text(
                  "Publish",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
