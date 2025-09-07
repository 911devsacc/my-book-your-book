import 'package:flutter/material.dart';
import '../../services/post_service.dart';
import '../../widgets/post_form.dart';

class PostPage extends StatefulWidget {
  final VoidCallback? onPostPublished;

  const PostPage({super.key, this.onPostPublished});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  bool _isLoading = false;

  Future<void> _publishPost(
    String bookName,
    String description,
    String faculty,
    String department,
    String exchangeType,
    String? exchangeFor,
  ) async {
    setState(() => _isLoading = true);

    try {
      await PostService.createPost(
        bookName: bookName,
        description: description,
        faculty: faculty,
        department: department,
        exchangeType: exchangeType,
        exchangeFor: exchangeFor,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post Published ✅")),
      );

      widget.onPostPublished?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error publishing post: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PostForm(
            isLoading: _isLoading,
            onSubmit: _publishPost,
          ),
        ],
      ),
    );
  }
}
