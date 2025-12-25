import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/emergency_provider.dart';
import '../../services/auth_service.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen> with SingleTickerProviderStateMixin {
  late AnimationController _flashController;
  bool _sosActivated = false;

  @override
  void initState() {
    super.initState();
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _flashController.dispose();
    super.dispose();
  }

  Future<void> _activateSOS() async {
    final emergencyProvider = context.read<EmergencyProvider>();
    final user = context.read<AuthService>().currentUser;

    if (user == null) return;

    if (emergencyProvider.contacts.isEmpty) {
      _showNoContactsDialog();
      return;
    }

    setState(() => _sosActivated = true);
    _flashController.repeat(reverse: true);

    await emergencyProvider.activateSOS(user.uid);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🚨 SOS Activated! Emergency contacts notified.'),
          backgroundColor: AppTheme.dangerColor,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _deactivateSOS() async {
    final emergencyProvider = context.read<EmergencyProvider>();
    
    await emergencyProvider.deactivateSOS();
    _flashController.stop();
    
    setState(() => _sosActivated = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SOS Deactivated'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  void _showNoContactsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Emergency Contacts'),
        content: const Text(
          'Please add emergency contacts before using SOS feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.emergencyContacts);
            },
            child: const Text('Add Contacts'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate SOS?'),
        content: const Text('Are you sure you want to deactivate the emergency alert?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deactivateSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: _sosActivated ? AppTheme.dangerColor : AppTheme.primaryColor,
      ),
      body: AnimatedBuilder(
        animation: _flashController,
        builder: (context, child) {
          return Container(
            color: _sosActivated
                ? Color.lerp(Colors.white, AppTheme.dangerColor, _flashController.value)
                : Colors.white,
            child: child,
          );
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // SOS Icon
                Icon(
                  Icons.warning_amber_rounded,
                  size: 100,
                  color: _sosActivated ? AppTheme.dangerColor : Colors.grey[400],
                ),
                
                const SizedBox(height: 24),
                
                // Title
                Text(
                  _sosActivated ? 'SOS ACTIVE!' : 'Emergency SOS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _sosActivated ? AppTheme.dangerColor : AppTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  _sosActivated
                      ? 'Your emergency contacts have been notified with your location. Help is on the way!'
                      : 'Press and hold the button below to send emergency alerts to your contacts with your current location.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                // Emergency Contacts Count
                Consumer<EmergencyProvider>(
                  builder: (context, emergencyProvider, _) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.contacts, color: AppTheme.primaryColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Emergency Contacts',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    '${emergencyProvider.contacts.length} contacts',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, AppRoutes.emergencyContacts);
                              },
                              child: const Text('Manage'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // SOS Button
                GestureDetector(
                  onLongPress: _sosActivated ? null : _activateSOS,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _sosActivated ? AppTheme.successColor : AppTheme.dangerColor,
                      boxShadow: [
                        BoxShadow(
                          color: (_sosActivated ? AppTheme.successColor : AppTheme.dangerColor)
                              .withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _sosActivated ? 'ACTIVE' : 'HOLD\nFOR\nSOS',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _sosActivated ? 'Tap below to deactivate' : 'Press and hold to activate',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                if (_sosActivated) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showDeactivateConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successColor,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Deactivate SOS'),
                  ),
                ],
                
                const SizedBox(height: 40),
                
                // Quick call buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickCallButton(
                      icon: Icons.local_police,
                      label: 'Police\n15',
                      onTap: () {
                        // Call police
                      },
                    ),
                    _buildQuickCallButton(
                      icon: Icons.local_hospital,
                      label: 'Ambulance\n1122',
                      onTap: () {
                        // Call ambulance
                      },
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickCallButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: AppTheme.primaryColor),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
