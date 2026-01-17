import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Last updated: December 30, 2025',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Introduction',
              'Welcome to Nigehbaan ("we," "our," or "us"). We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about our policy, or our practices with regards to your personal information, please contact us.',
            ),
            _buildSection(
              '2. Information We Collect',
              'We collect personal information that you voluntarily provide to us when registering at the Apps, expressing an interest in obtaining information about us or our products and services, when participating in activities on the Apps or otherwise contacting us.\n\nThe personal information that we collect depends on the context of your interactions with us and the Apps, the choices you make and the products and features you use. The personal information we collect can include the following:\n- Name and Contact Data\n- Credentials\n- Location Data (Essential for Safety Features)',
            ),
            _buildSection(
              '3. How We Use Your Information',
              'We use personal information collected via our Apps for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations.\n\n- To facilitate account creation and logon process.\n- To send administrative information to you.\n- To Request Feedback.\n- To protect our Services.\n- To providing location-based safety services.',
            ),
            _buildSection(
              '4. Sharing Your Information',
              'We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.',
            ),
             _buildSection(
              '5. Contact Us',
              'If you have questions or comments about this policy, you may email us at support@nigehbaan.app.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
}
