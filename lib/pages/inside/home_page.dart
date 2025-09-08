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
  bool _isSearching = false;  // Track search state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          firstChild: const Text(
            'My Book Your Book',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          secondChild: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search books...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.black87),
            onChanged: (val) {
              setState(() {
                searchQuery = val.toLowerCase().trim();
              });
            },
          ),
          crossFadeState: _isSearching 
              ? CrossFadeState.showSecond 
              : CrossFadeState.showFirst,
        ),
        actions: [
          // 🔎 Search toggle
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: Colors.green,
            ),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  searchQuery = '';
                }
              });
            },
          ),
          // 🔽 Filter by faculty → department
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.green),
            onPressed: () async {
              try {
                final result = await showDialog<String>(
                  context: context,
                  builder: (ctx) => SimpleDialog(
                    title: const Text('Select Faculty & Department'),
                    children: [
                      // Show faculties only if they have departments
                      ...AppConstants.faculties.where((faculty) {
                        final departments = AppConstants.departments[faculty];
                        return departments != null && departments.isNotEmpty;
                      }).map(
                        (faculty) => ExpansionTile(
                          title: Text(
                            faculty,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: [
                            // Safely handle departments for each faculty
                            ...(AppConstants.departments[faculty] ?? []).map(
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
                        child: const Text('Show All'),
                      ),
                    ],
                  ),
                );

                if (mounted) {
                  setState(() {
                    selectedDepartment = result;
                  });

                  // Show feedback about the filter
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result == null
                            ? 'Showing all departments'
                            : 'Filtered by: $result',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error applying filter. Please try again.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          //  Posts list
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
                  // Log the full error details
                  print('==== Firestore Query Error ====');
                  print('Error: ${snapshot.error}');
                  print('Stack trace: ${snapshot.stackTrace}');
                  print('Selected department: $selectedDepartment');
                  print('============================');

                  // Check if it's an index error
                  final error = snapshot.error.toString().toLowerCase();
                  if (error.contains('index') || error.contains('query requires')) {
                    print('Index error detected. Error details:');
                    print(snapshot.error);
                    print('Follow the error link above to create the missing index.');
                    
                    // Reset the filter and show error
                    Future.microtask(() {
                      setState(() {
                        selectedDepartment = null;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Missing Firestore index. Check console for details.',
                          ),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 5),
                        ),
                      );
                    });
                    return const Center(
                      child: Text(
                        "Index error - check console log",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.orange,
                        ),
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Error loading posts',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              selectedDepartment = null;
                            });
                          },
                          child: const Text('Show all departments'),
                        ),
                      ],
                    ),
                  );
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

                final docs = snapshot.data!.docs;
                
                // Early check for filtered results
                if (searchQuery.isNotEmpty) {
                  final filteredDocs = docs.where((doc) {
                    final post = PostModel.fromFirestore(doc);
                    return post.bookName.toLowerCase().contains(searchQuery) ||
                           post.description.toLowerCase().contains(searchQuery);
                  }).toList();
                  
                  if (filteredDocs.isEmpty) {
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
                  docs.clear();
                  docs.addAll(filteredDocs);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  // Add caching for better performance
                  cacheExtent: 100.0,
                  itemBuilder: (context, index) {
                    // Convert to PostModel only when the item is actually visible
                    final post = PostModel.fromFirestore(docs[index]);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: PostCard(
                        key: ValueKey(post.id),
                        post: post,
                        currentUserId: currentUser?.uid,
                        onDeleted: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Post deleted 🗑️")),
                          );
                        },
                      ),
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
  