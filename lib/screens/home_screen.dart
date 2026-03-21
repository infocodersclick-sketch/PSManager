import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';
import '../services/google_drive_sync_service.dart';
import 'login_screen.dart';
import 'add_edit_password_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vault'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
               themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => _showSyncBottomSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _buildBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditPasswordScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final storageService = Provider.of<StorageService>(context);
    final passwords = storageService.passwords;

    if (passwords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No passwords saved yet.\nTap + to add.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: passwords.length,
      itemBuilder: (context, index) {
        final entry = passwords[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.security)),
            title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(entry.username),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: entry.password));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied to clipboard')),
                );
              },
            ),
            onTap: () {
              Clipboard.setData(ClipboardData(text: entry.password));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password copied to clipboard')),
              );
            },
          ),
        );
      },
    );
  }

  void _showSyncBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<GoogleDriveSyncService>(
          builder: (context, syncService, child) {
            if (syncService.isSyncing) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Syncing with Google Drive...'),
                    ],
                  ),
                ),
              );
            }

            return SafeArea(
              child: Wrap(
                children: [
                   const ListTile(
                    title: Text('Google Drive Sync', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_upload),
                    title: const Text('Backup to Drive'),
                    subtitle: const Text('Uploads local vault to Drive'),
                    onTap: () async {
                      final success = await syncService.backupToDrive();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Backup successful' : 'Backup failed')),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_download),
                    title: const Text('Restore from Drive'),
                    subtitle: const Text('Overwrites local vault with Drive copy'),
                    onTap: () async {
                      final success = await syncService.restoreFromDrive();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(success ? 'Restore successful' : 'Restore failed (or no backup found)')),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
