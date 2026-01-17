import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../services/data_seeding_service.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
// import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsProvider>().loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthService>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    user?.email?[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              return Column(
                children: [
                  SwitchListTile(
                    title: Text('Settings'),
                    subtitle: const Text('Receive safety alerts'),
                    value: settings.notificationsEnabled,
                    onChanged: (value) {
                      settings.toggleNotifications(value);
                    },
                    secondary: const Icon(Icons.notifications),
                  ),
                  SwitchListTile(
                    title: const Text('Location Tracking'),
                    subtitle: const Text('Enable background location'),
                    value: settings.locationTrackingEnabled,
                    onChanged: (value) {
                      settings.toggleLocationTracking(value);
                    },
                    secondary: const Icon(Icons.location_on),
                  ),
                  SwitchListTile(
                    title: const Text('Sound'),
                    subtitle: const Text('Enable alert sounds'),
                    value: settings.soundEnabled,
                    onChanged: (value) {
                      settings.toggleSound(value);
                    },
                    secondary: const Icon(Icons.volume_up),
                  ),
                ],
              );
            },
          ),

          const Divider(),

          // Safety Section
          _buildSectionHeader('Safety Status'),
          ListTile(
            leading: const Icon(Icons.contacts),
            title: Text('Emergency Contacts'),
            subtitle: const Text('Manage your emergency contacts'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.emergencyContacts);
            },
          ),

          const Divider(),

          // Account Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: const Text('Edit your profile'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to profile screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to change password
            },
          ),

          const Divider(),

          // Developer Section (for testing/demo)
          _buildSectionHeader('Developer Options'),
          ListTile(
            leading: const Icon(Icons.data_usage, color: AppTheme.primaryColor),
            title: const Text('Seed Sample Data'),
            subtitle: const Text('Add demo incidents and safe zones'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showSeedDataDialog();
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Nigehbaan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              _showAboutDialog();
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.privacyPolicy);
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text('Terms & Conditions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.termsConditions);
            },
          ),

          const Divider(),

          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.dangerColor),
            title: Text(
              'Logout',
              style: const TextStyle(color: AppTheme.dangerColor),
            ),
            onTap: () {
              _showLogoutDialog();
            },
          ),

          const SizedBox(height: 24),

          // App Version
          Center(
            child: Text(
              'Nigehbaan v1.0.0',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Nigehbaan'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nigehbaan - Your Safety Companion',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Nigehbaan is a real-time women safety and smart navigation app that helps you travel safely with features like:',
            ),
            SizedBox(height: 8),
            Text('• Safety-scored routes'),
            Text('• Community reporting'),
            Text('• Emergency SOS'),
            Text('• Real-time alerts'),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthService>().signOut();
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showSeedDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seed Sample Data'),
        content: const Text(
          'This will add sample incidents and safe zones for major cities (Islamabad, Karachi, Lahore) to Firebase.\n\n'
          'This is useful for testing and demo purposes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                // Use seeding service
                final seedingService = DataSeedingService();
                final result = await seedingService.seedSampleData();

                if (mounted) {
                  Navigator.pop(context); // Close loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '✅ Seeded ${result['incidents']} incidents and ${result['safeZones']} safe zones',
                      ),
                      backgroundColor: AppTheme.successColor,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // Close loading
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error seeding data: $e'),
                      backgroundColor: AppTheme.dangerColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Seed Data'),
          ),
        ],
      ),
    );
  }
}
