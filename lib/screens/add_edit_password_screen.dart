import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class AddEditPasswordScreen extends StatefulWidget {
  final PasswordEntry? entry;
  const AddEditPasswordScreen({super.key, this.entry});

  @override
  State<AddEditPasswordScreen> createState() => _AddEditPasswordScreenState();
}

class _AddEditPasswordScreenState extends State<AddEditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _profilePasswordController;
  late final TextEditingController _notesController;

  bool _obscurePassword = true;
  bool _obscureProfilePassword = true;
  String _selectedCategory = 'general';
  bool get _isEditing => widget.entry != null;

  final List<Map<String, dynamic>> _categories = [
    {'value': 'general', 'label': 'General', 'icon': Icons.public_rounded, 'color': Color(0xFF0891B2)},
    {'value': 'bank', 'label': 'Banking', 'icon': Icons.account_balance_rounded, 'color': Color(0xFF059669)},
    {'value': 'social', 'label': 'Social Media', 'icon': Icons.people_alt_rounded, 'color': Color(0xFFD97706)},
    {'value': 'work', 'label': 'Work', 'icon': Icons.work_rounded, 'color': Color(0xFF7C3AED)},
    {'value': 'other', 'label': 'Other', 'icon': Icons.more_horiz_rounded, 'color': Color(0xFF6B7280)},
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.entry;
    _titleController = TextEditingController(text: e?.title ?? '');
    _usernameController = TextEditingController(text: e?.username ?? '');
    _passwordController = TextEditingController(text: e?.password ?? '');
    _profilePasswordController = TextEditingController(text: e?.profilePassword ?? '');
    _notesController = TextEditingController(text: e?.notes ?? '');
    _selectedCategory = e?.category ?? 'general';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _profilePasswordController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    final storageService = Provider.of<StorageService>(context, listen: false);

    final entry = PasswordEntry(
      id: widget.entry?.id,
      title: _titleController.text.trim(),
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      category: _selectedCategory,
      profilePassword: _selectedCategory == 'bank' && _profilePasswordController.text.isNotEmpty
          ? _profilePasswordController.text
          : null,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (_isEditing) {
      await storageService.updatePassword(entry);
    } else {
      await storageService.addPassword(entry);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCatMeta = _categories.firstWhere((c) => c['value'] == _selectedCategory);
    final selectedColor = selectedCatMeta['color'] as Color;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Password' : 'Add Password'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Save'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryIndigo),
              onPressed: _saveForm,
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category Selector
            _sectionLabel('Category'),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['value'];
                  final color = cat['color'] as Color;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat['value']),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat['icon'] as IconData, size: 16,
                                color: isSelected ? Colors.white : color),
                            const SizedBox(width: 6),
                            Text(cat['label'] as String,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : color,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Platform / Site Name
            _sectionLabel('Platform / Website Name'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'e.g. Gmail, SBI Bank, Instagram...',
                prefixIcon: Icon(selectedCatMeta['icon'] as IconData, color: selectedColor),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Platform name is required' : null,
            ),
            const SizedBox(height: 16),

            // Username / Email
            _sectionLabel('Username or Email'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _usernameController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'e.g. user@email.com or username',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Username is required' : null,
            ),
            const SizedBox(height: 16),

            // Password
            _sectionLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                hintText: 'Enter password...',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
            ),
            const SizedBox(height: 16),

            // Profile / ATM PIN — Only for bank category
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _selectedCategory == 'bank'
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Banking Only',
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      _sectionLabel('Profile / ATM PIN'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _profilePasswordController,
                    obscureText: _obscureProfilePassword,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. Profile password or ATM PIN...',
                      prefixIcon: const Icon(Icons.pin_outlined, color: Color(0xFF059669)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF059669), width: 2),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureProfilePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setState(() => _obscureProfilePassword = !_obscureProfilePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              secondChild: const SizedBox.shrink(),
            ),

            // Notes (Optional)
            _sectionLabel('Notes (Optional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Extra information about this account...',
                prefixIcon: Icon(Icons.notes_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(_isEditing ? Icons.save_rounded : Icons.add_circle_outline_rounded),
                label: Text(_isEditing ? 'Update Password' : 'Save Password'),
                onPressed: _saveForm,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.grey[600],
      letterSpacing: 0.3,
    ),
  );
}
