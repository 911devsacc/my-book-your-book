import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_constants.dart';
import '../../models/post_model.dart';
import '../../services/post_service.dart';
import '../../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  String? selectedDepartment;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'My Book Your Book',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
        ),
        centerTitle: true,
        actions: [
          // 🔽 Filter by faculty → department
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.green),
            onPressed: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('Select Faculty & Department'),
                  children: [
                    ...AppConstants.faculties.map(
                      (faculty) => ExpansionTile(
                        title: Text(
                          faculty,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        children: [
                          ...AppConstants.departments[faculty]!.map(
                            (dept) => ListTile(
                              title: Text(dept),
                              onTap: () => Navigator.pop(ctx, dept),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(ctx, null),
                      child: const Text('All Departments'),
                    ),
                  ],
                ),
              );

              setState(() {
                selectedDepartment = result;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.green),
                hintText: "Search books...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) {
                setState(() {
                  searchQuery = val.toLowerCase().trim();
                });
              },
            ),
          ),

          // 📚 Posts list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: PostService.getPosts(department: selectedDepartment),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posts available!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  );
                }

                // ✅ Convert Firestore docs → PostModel
                final posts = snapshot.data!.docs
                    .map((doc) => PostModel.fromFirestore(doc))
                    .where((post) {
                      if (searchQuery.isEmpty) return true;
                      return post.bookName.toLowerCase().contains(searchQuery) ||
                          post.description.toLowerCase().contains(searchQuery);
                    })
                    .toList();

                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      "No matching posts found!",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      currentUserId: currentUser?.uid,
                      onDeleted: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Post deleted 🗑️")),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
  