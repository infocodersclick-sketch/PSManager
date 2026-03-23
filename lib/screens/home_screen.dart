import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/google_drive_sync_service.dart';
import '../models/password_entry.dart';
import 'login_screen.dart';
import 'add_edit_password_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _filterCategory = 'all';
  String _searchQuery = '';

  final Map<String, Map<String, dynamic>> _categoryMeta = {
    'all':     {'icon': Icons.apps_rounded, 'color': const Color(0xFF4F46E5), 'label': 'All'},
    'general': {'icon': Icons.public_rounded, 'color': const Color(0xFF0891B2), 'label': 'General'},
    'bank':    {'icon': Icons.account_balance_rounded, 'color': const Color(0xFF059669), 'label': 'Banking'},
    'social':  {'icon': Icons.people_alt_rounded, 'color': const Color(0xFFD97706), 'label': 'Social'},
    'work':    {'icon': Icons.work_rounded, 'color': const Color(0xFF7C3AED), 'label': 'Work'},
    'other':   {'icon': Icons.more_horiz_rounded, 'color': const Color(0xFF6B7280), 'label': 'Other'},
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final storageService = Provider.of<StorageService>(context);
    final isDark = themeProvider.isDarkMode;

    final allPasswords = storageService.passwords;
    final filtered = allPasswords.where((e) {
      final matchCat = _filterCategory == 'all' || e.category == _filterCategory;
      final matchSearch = _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.username.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryIndigo, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('VaultKey'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
            onPressed: () => themeProvider.toggleTheme(!isDark),
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            onPressed: () => _showSyncSheet(context),
            tooltip: 'Sync',
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            tooltip: 'Logout',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search passwords...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _categoryMeta.entries.map((e) {
                final selected = _filterCategory == e.key;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: selected,
                    label: Text(e.value['label']),
                    avatar: Icon(e.value['icon'] as IconData, size: 16,
                      color: selected ? Colors.white : e.value['color'] as Color),
                    selectedColor: e.value['color'] as Color,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _filterCategory = e.key),
                  ),
                );
              }).toList(),
            ),
          ),
          // Summary banner
          if (allPasswords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _buildSummaryBanner(allPasswords, isDark),
            ),
          // Passwords list
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => _buildPasswordCard(context, filtered[index], isDark),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPasswordScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Password'),
      ),
    );
  }

  Widget _buildSummaryBanner(List<PasswordEntry> passwords, bool isDark) {
    final bankCount = passwords.where((e) => e.category == 'bank').length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1A40), const Color(0xFF1A1640)]
              : [const Color(0xFFEEECFF), const Color(0xFFE8E5FF)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2E2A5A) : const Color(0xFFD0CAFF),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.key_rounded, color: AppTheme.primaryIndigo, size: 18),
          const SizedBox(width: 8),
          Text('${passwords.length} passwords saved',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryIndigo)),
          if (bankCount > 0) ...[
            const SizedBox(width: 12),
            Container(width: 1, height: 14, color: Colors.indigo.shade200),
            const SizedBox(width: 12),
            const Icon(Icons.account_balance_rounded, color: Color(0xFF059669), size: 16),
            const SizedBox(width: 4),
            Text('$bankCount banking', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w500)),
          ],
        ],
      ),
    );
  }

  Widget _buildPasswordCard(BuildContext context, PasswordEntry entry, bool isDark) {
    final catMeta = _categoryMeta[entry.category] ?? _categoryMeta['other']!;
    final catColor = catMeta['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showPasswordDetail(context, entry),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(catMeta['icon'] as IconData, color: catColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 3),
                      Text(entry.username, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                      if (entry.category == 'bank' && entry.profilePassword != null && entry.profilePassword!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('Profile PIN secured',
                                style: TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w500)),
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded),
                  onSelected: (value) {
                    if (value == 'copy') {
                      Clipboard.setData(ClipboardData(text: entry.password));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password copied!')));
                    } else if (value == 'edit') {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => AddEditPasswordScreen(entry: entry)));
                    } else if (value == 'delete') {
                      _confirmDelete(context, entry);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'copy', child: ListTile(
                        leading: Icon(Icons.copy_rounded), title: Text('Copy Password'), dense: true)),
                    const PopupMenuItem(value: 'edit', child: ListTile(
                        leading: Icon(Icons.edit_rounded), title: Text('Edit'), dense: true)),
                    const PopupMenuItem(value: 'delete', child: ListTile(
                        leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)), dense: true)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPasswordDetail(BuildContext context, PasswordEntry entry) {
    final catMeta = _categoryMeta[entry.category] ?? _categoryMeta['other']!;
    final catColor = catMeta['color'] as Color;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                  child: Icon(catMeta['icon'] as IconData, color: catColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(entry.category.toUpperCase(),
                          style: TextStyle(fontSize: 12, color: catColor, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded, color: AppTheme.primaryIndigo),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => AddEditPasswordScreen(entry: entry)));
                  },
                ),
              ],
            ),
            const Divider(height: 28),
            _detailRow(context, 'Username / Email', entry.username, Icons.person_outline_rounded),
            const SizedBox(height: 12),
            _detailRow(context, 'Password', entry.password, Icons.lock_outline_rounded, obscure: true),
            if (entry.category == 'bank' && entry.profilePassword != null && entry.profilePassword!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow(context, 'Profile / ATM PIN', entry.profilePassword!, Icons.pin_outlined, obscure: true, color: const Color(0xFF059669)),
            ],
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _detailRow(context, 'Notes', entry.notes!, Icons.notes_rounded),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(BuildContext context, String label, String value, IconData icon,
      {bool obscure = false, Color? color}) {
    return StatefulBuilder(builder: (ctx, setInnerState) {
      bool hidden = obscure;
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color?.withOpacity(0.08) ?? (Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkCardAlt
              : const Color(0xFFF5F5FF)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color?.withOpacity(0.2) ??
            (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2A2A4A) : Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color ?? AppTheme.primaryIndigo),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 2),
                  StatefulBuilder(builder: (ctx2, ss) => Text(
                    obscure ? (hidden ? '• • • • • • • •' : value) : value,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500,
                        color: color ?? Theme.of(context).colorScheme.onSurface),
                  )),
                ],
              ),
            ),
            if (obscure)
              IconButton(
                icon: Icon(hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18),
                onPressed: () => setInnerState(() => hidden = !hidden),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$label copied!')));
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context, PasswordEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Password'),
        content: Text('Delete "${entry.title}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<StorageService>(context, listen: false).deletePassword(entry.id!);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.lock_open_rounded, size: 40, color: AppTheme.primaryIndigo),
          ),
          const SizedBox(height: 16),
          Text(_searchQuery.isNotEmpty || _filterCategory != 'all'
              ? 'No matching passwords found'
              : 'Your vault is empty',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_searchQuery.isNotEmpty || _filterCategory != 'all'
              ? 'Try a different search or filter'
              : 'Tap + to add your first password',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _showSyncSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Consumer<GoogleDriveSyncService>(
        builder: (context, syncService, child) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4,
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 20),
                const Text('Google Drive Sync', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (syncService.isSyncing)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ))
                else ...[
                  _syncButton(
                    icon: Icons.cloud_upload_rounded,
                    label: 'Backup to Drive',
                    subtitle: 'Upload local vault to Google Drive',
                    color: AppTheme.primaryIndigo,
                    onTap: () async {
                      try {
                        final success = await syncService.backupToDrive();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? '✓ Backup successful' : '✗ Backup failed (no Drive access)')));
                      } catch (e) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('✗ Error: ${e.toString().split('\n').first}'), duration: const Duration(seconds: 5)));
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  _syncButton(
                    icon: Icons.cloud_download_rounded,
                    label: 'Restore from Drive',
                    subtitle: 'Overwrite local vault with Drive copy',
                    color: const Color(0xFF059669),
                    onTap: () async {
                      try {
                        final success = await syncService.restoreFromDrive();
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(success ? '✓ Restore successful' : '✗ No backup found')));
                      } catch (e) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('✗ Error: ${e.toString().split('\n').first}'), duration: const Duration(seconds: 5)));
                      }
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _syncButton({required IconData icon, required String label, required String subtitle,
      required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.06),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
