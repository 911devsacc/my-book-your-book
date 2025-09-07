import 'package:flutter/material.dart';
import 'package:my_book_your_book/widgets/faculty_department_picker.dart';

class RequestDialog extends StatefulWidget {
  final String bookName;
  final Function(String faculty, String department) onSendRequest;

  const RequestDialog({
    super.key,
    required this.bookName,
    required this.onSendRequest,
  });

  @override
  State<RequestDialog> createState() => _RequestDialogState();
}

class _RequestDialogState extends State<RequestDialog> {
  String? _selectedFaculty;
  String? _selectedDepartment;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send Request'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Requesting: ${widget.bookName}'),
          const SizedBox(height: 16),
          const Text('Select your faculty and department:'),
          const SizedBox(height: 8),
          FacultyDepartmentPicker(
            onSelect: (faculty, department) {
              setState(() {
                _selectedFaculty = faculty;
                _selectedDepartment = department;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedFaculty == null || _selectedDepartment == null
              ? null
              : () {
                  widget.onSendRequest(_selectedFaculty!, _selectedDepartment!);
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Send Request'),
        ),
      ],
    );
  }
}
