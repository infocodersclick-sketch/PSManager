import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';

class AddEditPasswordScreen extends StatefulWidget {
  const AddEditPasswordScreen({Key? key}) : super(key: key);

  @override
  _AddEditPasswordScreenState createState() => _AddEditPasswordScreenState();
}

class _AddEditPasswordScreenState extends State<AddEditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final entry = PasswordEntry(
        title: _titleController.text,
        username: _usernameController.text,
        password: _passwordController.text,
      );
      await Provider.of<StorageService>(context, listen: false).addPassword(entry);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Password'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Platform / Website Name',
                prefixIcon: Icon(Icons.language),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username or Email',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Required field' : null,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveForm,
              child: const Text('Save Password'),
            ),
          ],
        ),
      ),
    );
  }
}
