// lib/screens/baby_form.dart
import 'package:flutter/material.dart';
import '../models/baby_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';


class BabyForm extends StatefulWidget {
  const BabyForm({Key? key}) : super(key: key);
 
  @override
  State<BabyForm> createState() => _BabyFormState();
}

class _BabyFormState extends State<BabyForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  DateTime? _birthDate;

  Future<void> _saveBabyProfile() async {
    if (_formKey.currentState!.validate()) {
      final newBaby = BabyProfile(  
        id: DateTime.now().millisecondsSinceEpoch,
        name: _nameController.text,
        birthDate: _birthDate?.toIso8601String() ?? '',
        notes: _notesController.text,
        allergies: _allergiesController.text,
        feedingPreferences: '', 
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('babyCreated', true);

      Navigator.pushReplacementNamed(context, '/dashboard', arguments: newBaby);
    }
  }

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2023),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Baby Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Baby Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(  
                readOnly: true,
                onTap: _pickBirthDate,
                decoration: InputDecoration(  
                  labelText: _birthDate == null
                      ? 'Select Birth Date'
                      : 'Birth Date: ${_birthDate!.toLocal().toIso8601String().split(' ')[0]}',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(  
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 12),
              TextFormField(  
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(  
                onPressed: _saveBabyProfile,
                child: const Text("Save and Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}