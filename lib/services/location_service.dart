import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../models/location.dart';
import '../models/location_location.dart';

class LocationService {
  final ApiClient api;

  LocationService({required this.api});

  /// ==============================
  /// ADD LOCATION
  /// ==============================
  Future<AddLocationResponse> addLocation(String locationName) async {
    debugPrint('🟡 ADDING LOCATION: $locationName');

    final response = await api.post(
      '/api/v1/admin/location',
      body: {'locationName': locationName},
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if ((response.statusCode != 200 && response.statusCode != 201) ||
        data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to add location');
    }

    return AddLocationResponse.fromJson(data);
  }

  /// ==============================
  /// FETCH ALL LOCATIONS
  /// ==============================
  Future<List<Location>> fetchLocations() async {
    debugPrint('🟡 FETCHING LOCATIONS');

    final response = await api.get('/api/v1/admin/location');

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Failed to fetch locations');
    }

    final List list = data['responseBody'] ?? [];
    return list.map((e) => Location.fromJson(e)).toList();
  }

  /// ==============================
  /// UPDATE LOCATION
  /// ==============================
  Future<void> updateLocation(String locationId, String locationName) async {
    debugPrint('🟡 UPDATING LOCATION: $locationId');
    debugPrint('📤 NEW NAME: $locationName');

    final response = await api.patch(
      '/api/v1/admin/location/$locationId',
      body: {'locationName': locationName},
    );

    debugPrint('📥 UPDATE STATUS: ${response.statusCode}');
    debugPrint('📥 UPDATE BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['responseMessage'] ?? 'Failed to update location');
    }

    if (data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Update request failed');
    }
  }

  /// ==============================
  /// DELETE LOCATION
  /// ==============================
  Future<void> deleteLocation(String locationId) async {
    debugPrint('🟡 DELETING LOCATION: $locationId');

    final response = await api.delete('/api/v1/admin/location/$locationId');

    debugPrint('📥 DELETE STATUS: ${response.statusCode}');
    debugPrint('📥 DELETE BODY: ${response.body}');

    // Handle 204 No Content response
    if (response.statusCode == 204) {
      return;
    }

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['responseMessage'] ?? 'Failed to delete location');
    }

    if (data['responseSuccessful'] != true) {
      throw Exception(data['responseMessage'] ?? 'Delete request failed');
    }
  }
}
