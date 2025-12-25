import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class PlaceModel {
  final String placeId;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String type; // hospital, police, pharmacy
  final double? rating;

  PlaceModel({
    required this.placeId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.type,
    this.rating,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json, String type) {
    final location = json['geometry']['location'];
    return PlaceModel(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      latitude: location['lat'] ?? 0.0,
      longitude: location['lng'] ?? 0.0,
      address: json['vicinity'] ?? json['formatted_address'] ?? '',
      type: type,
      rating: json['rating']?.toDouble(),
    );
  }
}

class PlacesService {
  // TODO: Replace with your actual Google Places API key
  static const String _apiKey = 'YOUR_GOOGLE_PLACES_API_KEY';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';

  // Search for nearby hospitals
  Future<List<PlaceModel>> findNearbyHospitals({
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    return await _findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'hospital',
      radius: radius,
    );
  }

  // Search for nearby police stations
  Future<List<PlaceModel>> findNearbyPoliceStations({
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    return await _findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'police',
      radius: radius,
    );
  }

  // Search for nearby pharmacies
  Future<List<PlaceModel>> findNearbyPharmacies({
    required double latitude,
    required double longitude,
    int radius = 3000,
  }) async {
    return await _findNearbyPlaces(
      latitude: latitude,
      longitude: longitude,
      type: 'pharmacy',
      radius: radius,
    );
  }

  // Generic nearby places search
  Future<List<PlaceModel>> _findNearbyPlaces({
    required double latitude,
    required double longitude,
    required String type,
    int radius = 5000,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .map((place) => PlaceModel.fromJson(place, type))
              .toList();
        } else {
          debugPrint('Places API error: ${data['status']}');
          return [];
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching nearby places: $e');
      return [];
    }
  }

  // Get place details
  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching place details: $e');
      return null;
    }
  }

  // Search places by text query
  Future<List<PlaceModel>> searchPlaces({
    required String query,
    required double latitude,
    required double longitude,
    int radius = 5000,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/textsearch/json?query=$query&location=$latitude,$longitude&radius=$radius&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          return results
              .map((place) => PlaceModel.fromJson(place, 'search'))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error searching places: $e');
      return [];
    }
  }
}
