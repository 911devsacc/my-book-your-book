import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/styles.dart';

class FacultyDepartmentPicker extends StatefulWidget {
  final String? initialFaculty;
  final String? initialDepartment;
  final Function(String faculty, String department) onSelect;
  final bool showDivider;

  const FacultyDepartmentPicker({
    super.key,
    this.initialFaculty,
    this.initialDepartment,
    required this.onSelect,
    this.showDivider = true,
  });

  @override
  State<FacultyDepartmentPicker> createState() => _FacultyDepartmentPickerState();
}

class _FacultyDepartmentPickerState extends State<FacultyDepartmentPicker> {
  String? _selectedFaculty;
  String? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _selectedFaculty = widget.initialFaculty;
    _selectedDepartment = widget.initialDepartment;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Faculty Dropdown
        DropdownButtonFormField<String>(
          value: _selectedFaculty,
          decoration: InputDecoration(
            labelText: 'Faculty',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: 10,
            ),
          ),
          items: AppConstants.faculties.map((faculty) {
            return DropdownMenuItem(
              value: faculty,
              child: Text(
                faculty,
                style: AppTextStyles.bodyText,
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedFaculty = value;
              _selectedDepartment = null; // Reset department when faculty changes
            });
            if (value != null && AppConstants.departments[value]!.isNotEmpty) {
              // Auto-select first department if there's only one
              if (AppConstants.departments[value]!.length == 1) {
                _selectedDepartment = AppConstants.departments[value]![0];
                widget.onSelect(value, _selectedDepartment!);
              }
            } else if (value != null) {
              // If there are no departments, we can still call onSelect with an empty string
              widget.onSelect(value, '');
            }
          },
        ),
        
        if (widget.showDivider) const SizedBox(height: AppDimensions.spacingMedium),

        // Department Dropdown
        if (_selectedFaculty != null)
          DropdownButtonFormField<String>(
            value: _selectedDepartment,
            decoration: InputDecoration(
              labelText: 'Department',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.paddingMedium,
                vertical: 10,
              ),
            ),
            items: AppConstants.departments[_selectedFaculty]!.map((department) {
              return DropdownMenuItem(
                value: department,
                child: Text(
                  department,
                  style: AppTextStyles.bodyText,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDepartment = value;
              });
              if (value != null) {
                widget.onSelect(_selectedFaculty!, value);
              }
            },
          ),
      ],
    );
  }
}
