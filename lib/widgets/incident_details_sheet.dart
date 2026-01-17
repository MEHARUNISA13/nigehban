import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/incident_model.dart';
import '../config/theme.dart';

class IncidentDetailsSheet extends StatelessWidget {
  final IncidentModel incident;
  final double? distanceInMeters;
  final VoidCallback? onClose;

  const IncidentDetailsSheet({
    super.key,
    required this.incident,
    this.distanceInMeters,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incident Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose ?? () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Incident type and severity
          Row(
            children: [
              _buildTypeChip(),
              const SizedBox(width: 8),
              _buildSeverityChip(),
            ],
          ),
          const SizedBox(height: 16),

          // Distance (if available)
          if (distanceInMeters != null) ...[
            Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  _formatDistance(distanceInMeters!),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Address
          if (incident.address != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.place, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    incident.address!,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Timestamp
          Row(
            children: [
              const Icon(Icons.access_time, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _formatTimestamp(incident.timestamp),
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            incident.description,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 16),

          // Verification status
          Row(
            children: [
              Icon(
                incident.verified ? Icons.verified : Icons.info_outline,
                size: 20,
                color: incident.verified ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                incident.verified
                    ? 'Verified incident'
                    : 'Unverified (${incident.verificationCount} reports)',
                style: TextStyle(
                  color: incident.verified ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openInMaps(incident.latitude, incident.longitude),
                  icon: const Icon(Icons.directions),
                  label: const Text('Get Directions'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement report as resolved
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Mark Safe'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip() {
    Color color;
    IconData icon;

    switch (incident.type) {
      case IncidentType.harassment:
        color = Colors.red;
        icon = Icons.warning;
        break;
      case IncidentType.theft:
        color = Colors.orange;
        icon = Icons.local_police;
        break;
      case IncidentType.assault:
        color = Colors.deepOrange;
        icon = Icons.dangerous;
        break;
      case IncidentType.suspiciousActivity:
        color = Colors.amber;
        icon = Icons.visibility;
        break;
      case IncidentType.other:
        color = Colors.grey;
        icon = Icons.info;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 18, color: Colors.white),
      label: Text(
        incident.typeDisplayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildSeverityChip() {
    Color color;

    switch (incident.severity) {
      case IncidentSeverity.critical:
        color = Colors.red.shade900;
        break;
      case IncidentSeverity.high:
        color = Colors.red;
        break;
      case IncidentSeverity.medium:
        color = Colors.orange;
        break;
      case IncidentSeverity.low:
        color = Colors.yellow.shade700;
        break;
    }

    return Chip(
      label: Text(
        incident.severityDisplayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m away';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km away';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  void _openInMaps(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}
