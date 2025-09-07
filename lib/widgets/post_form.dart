import 'package:flutter/material.dart';
import 'package:my_book_your_book/widgets/faculty_department_picker.dart';
import '../constants/app_constants.dart';
import '../widgets/app_form_fields.dart';

class PostForm extends StatefulWidget {
  final void Function(String, String, String, String, String, String?)
      onSubmit;
  final bool isLoading;

  const PostForm({
    super.key,
    required this.onSubmit,
    this.isLoading = false,
  });

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final _formKey = GlobalKey<FormState>();
  final _bookNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _exchangeForController = TextEditingController();

  String? _selectedFaculty;
  String? _selectedDepartment;
  String _exchangeType = "free";

  @override
  void dispose() {
    _bookNameController.dispose();
    _descriptionController.dispose();
    _exchangeForController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedFaculty == null || _selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a faculty and department.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onSubmit(
      _bookNameController.text,
      _descriptionController.text,
      _selectedFaculty!,
      _selectedDepartment!,
      _exchangeType,
      _exchangeType == "exchange" ? _exchangeForController.text : null,
    );

    _formKey.currentState!.reset();
    _bookNameController.clear();
    _descriptionController.clear();
    _exchangeForController.clear();
    setState(() {
      _selectedFaculty = null;
      _selectedDepartment = null;
      _exchangeType = "free";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _bookNameController,
            decoration: AppFormFields.buildInputDecoration("Book Name"),
            validator: (value) =>
                value == null || value.isEmpty ? "Enter book name" : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            maxLength: 200,
            maxLines: 3,
            decoration: AppFormFields.buildInputDecoration("Description"),
            validator: (value) =>
                value == null || value.isEmpty ? "Enter description" : null,
          ),
          const SizedBox(height: 16),
          FacultyDepartmentPicker(
            onSelect: (faculty, department) {
              setState(() {
                _selectedFaculty = faculty;
                _selectedDepartment = department;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("For Free"),
                  value: "free",
                  groupValue: _exchangeType,
                  activeColor: Colors.green,
                  onChanged: (value) => setState(() => _exchangeType = value!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text("In Exchange"),
                  value: "exchange",
                  groupValue: _exchangeType,
                  activeColor: Colors.green,
                  onChanged: (value) => setState(() => _exchangeType = value!),
                ),
              ),
            ],
          ),
          if (_exchangeType == "exchange") ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _exchangeForController,
              decoration: AppFormFields.buildInputDecoration("Exchange For"),
              validator: (value) {
                if (_exchangeType == "exchange" &&
                    (value == null || value.isEmpty)) {
                  return "Specify what you want in exchange";
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: AppFormFields.elevatedButtonStyle,
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Publish",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
