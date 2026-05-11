import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/habit_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enableNotifications = true;
  bool _enableOfflineMode = true;
// String _theme = 'light';

  @override
  Widget build(BuildContext context) {
Consumer2<HabitProvider, ThemeProvider>(
      builder: (context, habitProvider, themeProvider, _) {
        final String _theme = themeProvider.themeMode == ThemeMode.light ? 'light' : themeProvider.themeMode == ThemeMode.dark ? 'dark' : 'system';
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Settings
                _buildSectionTitle(context, 'App Settings'),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Notifications'),
                        subtitle: const Text('Get reminders for your habits'),
                        value: _enableNotifications,
                        onChanged: (value) {
                          setState(() => _enableNotifications = value);
                        },
                      ),
                      const Divider(height: 0),
                      SwitchListTile(
                        title: const Text('Offline Mode'),
                        subtitle:
                            const Text('Sync changes when connection returns'),
                        value: _enableOfflineMode,
                        onChanged: (value) {
                          setState(() => _enableOfflineMode = value);
                        },
                      ),
                      const Divider(height: 0),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Theme'),
                            DropdownButton<String>(
                              value: _theme,
                              items: const [
                                DropdownMenuItem(
                                  value: 'light',
                                  child: Text('Light'),
                                ),
                                DropdownMenuItem(
                                  value: 'dark',
                                  child: Text('Dark'),
                                ),
                                DropdownMenuItem(
                                  value: 'system',
                                  child: Text('System'),
                                ),
                              ],
                              onChanged: (value) async {
                                ThemeMode mode;
                                switch (value) {
                                  case 'light':
                                    mode = ThemeMode.light;
                                    break;
                                  case 'dark':
                                    mode = ThemeMode.dark;
                                    break;
                                  default:
                                    mode = ThemeMode.system;
                                }
                                await themeProvider.setTheme(mode);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Data Management
                _buildSectionTitle(context, 'Data Management'),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Export Habits'),
                        subtitle:
                            const Text('Download your habits as encrypted data'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showExportDialog(context, habitProvider),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        title: const Text('Import Habits'),
                        subtitle:
                            const Text('Restore habits from backup'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showImportDialog(context, habitProvider),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        title: const Text('Clear All Data'),
                        subtitle: const Text('Delete all habits permanently'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () =>
                            _showClearDataDialog(context, habitProvider),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // About
                _buildSectionTitle(context, 'About'),
                Card(
                  elevation: 2,
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text('App Version'),
                        trailing: Text('1.0.0'),
                      ),
                      const Divider(height: 0),
                      ListTile(
                        title: const Text('License'),
                        subtitle: const Text('MIT License'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _showAboutDialog(context),
                      ),
                      const Divider(height: 0),
                      const ListTile(
                        title: Text('Built with Flutter'),
                        subtitle: Text('Cross-platform application'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Info Cards
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your data is encrypted and secured locally on your device.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showExportDialog(BuildContext context, HabitProvider habitProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Habits'),
        content: const Text(
          'Your habits will be encrypted and saved. You can restore them later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await habitProvider.exportHabits();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Habits exported successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Export failed: $e')),
                  );
                }
              }
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, HabitProvider habitProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Habits'),
        content: const Text(
          'Paste your encrypted backup data below:',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implementation for paste from clipboard
              Navigator.pop(context);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, HabitProvider habitProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your habits and data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              habitProvider.clearAllHabits();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child:
                const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Habit Tracker',
      applicationVersion: '1.0.0',
      applicationLegalese: 'MIT License © 2024',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Habit Tracker helps you build better habits with daily tracking, statistics, and motivational streaks.',
        ),
      ],
    );
  }
}
