import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/birthday.dart';
import '../services/storage_service.dart';
import '../services/error_service.dart';

class AddBirthdayDialog extends StatefulWidget {
  final StorageService storageService;
  final DateTime? initialDate;

  const AddBirthdayDialog({Key? key, required this.storageService, this.initialDate}) : super(key: key);

  @override
  State<AddBirthdayDialog> createState() => _AddBirthdayDialogState();
}

class _AddBirthdayDialogState extends State<AddBirthdayDialog> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _knowsYear = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveBirthday() async {
    if (_nameController.text.isEmpty || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter name and date.')),
      );
      return;
    }
    
    final finalDate = _knowsYear 
        ? _selectedDate! 
        : DateTime(0, _selectedDate!.month, _selectedDate!.day);

    final newBirthday = Birthday(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      date: finalDate,
    );

    try {
      await widget.storageService.addBirthday(newBirthday);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(true);
    } catch (e, st) {
      logError(e, st);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Birthday'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Friend\'s Name'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedDate == null
                        ? 'No Date Chosen!'
                        : DateFormat.yMd().format(_selectedDate!),
                  ),
                ),
                TextButton(
                  onPressed: _presentDatePicker,
                  child: const Text('Choose Date', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: _knowsYear,
                  onChanged: (val) {
                    setState(() {
                      _knowsYear = val ?? true;
                    });
                  },
                ),
                const Text('Include birth year (shows age)'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveBirthday,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
