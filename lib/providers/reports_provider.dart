import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';

class ReportsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  List<ReportModel> _reports = [];
  List<ReportModel> _filteredReports = [];
  ReportCategory? _selectedCategory;
  bool _isLoading = false;

  ReportsProvider({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  List<ReportModel> get reports => _filteredReports.isEmpty ? _reports : _filteredReports;
  ReportCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;

  // Listen to all reports
  void listenToReports() {
    _firestoreService.getReports().listen((reportsList) {
      _reports = reportsList;
      _applyFilter();
      notifyListeners();
    });
  }

  // Filter by category
  void filterByCategory(ReportCategory? category) {
    _selectedCategory = category;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedCategory == null) {
      _filteredReports = [];
    } else {
      _filteredReports = _reports
          .where((report) => report.category == _selectedCategory)
          .toList();
    }
  }

  // Create new report
  Future<bool> createReport(ReportModel report) async {
    _isLoading = true;
    notifyListeners();

    final reportId = await _firestoreService.createReport(report);
    
    _isLoading = false;
    notifyListeners();

    return reportId != null;
  }

  // Upvote report
  Future<void> upvoteReport(String reportId) async {
    await _firestoreService.upvoteReport(reportId);
  }

  // Get nearby reports
  Future<List<ReportModel>> getNearbyReports({
    required double latitude,
    required double longitude,
    double radiusInKm = 5.0,
  }) async {
    return await _firestoreService.getNearbyReports(
      latitude: latitude,
      longitude: longitude,
      radiusInKm: radiusInKm,
    );
  }
}
