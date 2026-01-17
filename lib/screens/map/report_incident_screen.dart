import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/incident_model.dart';
import '../../providers/safety_map_provider.dart';
import '../../providers/location_provider.dart';
import '../../services/auth_service.dart';
import '../../config/theme.dart';

class ReportIncidentScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const ReportIncidentScreen({super.key, this.initialLocation});

  @override
  State<ReportIncidentScreen> createState() => _ReportIncidentScreenState();
}

class _ReportIncidentScreenState extends State<ReportIncidentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  IncidentType _selectedType = IncidentType.other;
  IncidentSeverity _selectedSeverity = IncidentSeverity.medium;
  LatLng? _selectedLocation;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    if (_selectedLocation == null) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = context.read<LocationProvider>();
    final position = locationProvider.currentPosition;
    if (position != null) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = context.read<AuthService>().currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final incident = IncidentModel(
        id: '',
        type: _selectedType,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        severity: _selectedSeverity,
        description: _descriptionController.text.trim(),
        timestamp: DateTime.now(),
        reportedBy: user.uid,
      );

      final success = await context.read<SafetyMapProvider>().reportIncident(incident);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incident reported successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        throw Exception('Failed to submit report');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Incident'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident Type
              Text(
                'Incident Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IncidentType.values.map((type) {
                  return ChoiceChip(
                    label: Text(_getTypeDisplayName(type)),
                    selected: _selectedType == type,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedType = type);
                      }
                    },
                    selectedColor: AppTheme.primaryColor,
                    labelStyle: TextStyle(
                      color: _selectedType == type ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Severity Level
              Text(
                'Severity Level',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: IncidentSeverity.values.map((severity) {
                  return ChoiceChip(
                    label: Text(_getSeverityDisplayName(severity)),
                    selected: _selectedSeverity == severity,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedSeverity = severity);
                      }
                    },
                    selectedColor: _getSeverityColor(severity),
                    labelStyle: TextStyle(
                      color: _selectedSeverity == severity ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Location
              Text(
                'Location',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                  title: Text(
                    _selectedLocation != null
                        ? '${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}'
                        : 'No location selected',
                  ),
                  subtitle: const Text('Tap to change location'),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    // TODO: Implement location picker
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Location picker coming soon!')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Describe what happened...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeDisplayName(IncidentType type) {
    switch (type) {
      case IncidentType.harassment:
        return 'Harassment';
      case IncidentType.theft:
        return 'Theft';
      case IncidentType.assault:
        return 'Assault';
      case IncidentType.suspiciousActivity:
        return 'Suspicious';
      case IncidentType.other:
        return 'Other';
    }
  }

  String _getSeverityDisplayName(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.low:
        return 'Low';
      case IncidentSeverity.medium:
        return 'Medium';
      case IncidentSeverity.high:
        return 'High';
      case IncidentSeverity.critical:
        return 'Critical';
    }
  }

  Color _getSeverityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.critical:
        return Colors.red.shade900;
      case IncidentSeverity.high:
        return Colors.red;
      case IncidentSeverity.medium:
        return Colors.orange;
      case IncidentSeverity.low:
        return Colors.yellow.shade700;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
