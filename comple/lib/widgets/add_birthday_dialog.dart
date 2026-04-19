import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/birthday.dart';
import '../services/storage_service.dart';

class AddBirthdayDialog extends StatefulWidget {
  final StorageService storageService;

  const AddBirthdayDialog({Key? key, required this.storageService}) : super(key: key);

  @override
  State<AddBirthdayDialog> createState() => _AddBirthdayDialogState();
}

class _AddBirthdayDialogState extends State<AddBirthdayDialog> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  bool _knowsYear = true;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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

    await widget.storageService.addBirthday(newBirthday);
    
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop(true);
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
