import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/emergency_contact.dart';
import '../services/firestore_service.dart';
import '../services/sos_service.dart';

class EmergencyProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final SOSService _sosService;
  
  List<EmergencyContact> _contacts = [];
  bool _isSOSActive = false;

  EmergencyProvider({
    required FirestoreService firestoreService,
    required SOSService sosService,
  })  : _firestoreService = firestoreService,
        _sosService = sosService {
    _loadContacts();
    _sosService.addListener(_onSOSUpdate);
  }

  List<EmergencyContact> get contacts => _contacts;
  bool get isSOSActive => _isSOSActive;

  void _onSOSUpdate() {
    _isSOSActive = _sosService.isSOSActive;
    notifyListeners();
  }

  // Load emergency contacts
  Future<void> _loadContacts() async {
    // Contacts will be loaded from Firestore when user logs in
    // For now, just initialize empty list
    _contacts = [];
  }

  // Load contacts from Firestore
  Future<void> loadContactsFromFirestore(String userId) async {
    final contacts = await _firestoreService.getEmergencyContacts(userId);
    _contacts = contacts;
    notifyListeners();
  }

  // Add emergency contact
  Future<void> addContact(EmergencyContact contact, String userId) async {
    _contacts.add(contact);
    await _saveContacts(userId);
    notifyListeners();
  }

  // Remove emergency contact
  Future<void> removeContact(String contactId, String userId) async {
    _contacts.removeWhere((c) => c.id == contactId);
    await _saveContacts(userId);
    notifyListeners();
  }

  // Update emergency contact
  Future<void> updateContact(EmergencyContact contact, String userId) async {
    final index = _contacts.indexWhere((c) => c.id == contact.id);
    if (index != -1) {
      _contacts[index] = contact;
      await _saveContacts(userId);
      notifyListeners();
    }
  }

  // Save contacts to Firestore only
  Future<void> _saveContacts(String userId) async {
    await _firestoreService.saveEmergencyContacts(userId, _contacts);
  }

  // Activate SOS
  Future<void> activateSOS(String userId) async {
    await _sosService.activateSOS(
      userId: userId,
      contacts: _contacts,
    );
  }

  // Deactivate SOS
  Future<void> deactivateSOS() async {
    await _sosService.deactivateSOS();
  }

  @override
  void dispose() {
    _sosService.removeListener(_onSOSUpdate);
    super.dispose();
  }
}
