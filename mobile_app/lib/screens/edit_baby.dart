import 'package:flutter/material.dart';
import '../services/baby_service.dart';


class EditBaby extends StatefulWidget {
  final Map<String, dynamic> baby;
  
  const EditBaby({Key? key, required this.baby}) : super(key: key);

  @override
  State<EditBaby> createState() => _EditBabyState();
}

class _EditBabyState extends State<EditBaby> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _birthDateController;
  late TextEditingController _feedingPreferencesController;
  late TextEditingController _allergiesController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.baby['name']);
    _birthDateController = TextEditingController(text: widget.baby['birth_date']);
    _feedingPreferencesController = TextEditingController(text: widget.baby['feeding_preferences'] ?? '');
    _allergiesController = TextEditingController(text: widget.baby['allergies'] ?? '');
    _notesController = TextEditingController(text: widget.baby['notes'] ?? '');
  }

  Future<void> _updateBaby() async {
    await BabyService().updateBabyProfile(
      docId: widget.baby['id'],
      name: _nameController.text,
      birthDate: _birthDateController.text,
      feedingPreferences: _feedingPreferencesController.text,
      allergies: _allergiesController.text,
      notes: _notesController.text,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Baby profile updated successfully!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Baby Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _birthDateController,
                decoration: const InputDecoration(labelText: 'Birth Date'),
              ),
              TextFormField(
                controller: _feedingPreferencesController,
                decoration: const InputDecoration(labelText: 'Feeding Preferences'),
              ),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateBaby,
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}