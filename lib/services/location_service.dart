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
      body: {
        'locationName': locationName,
      },
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if ((response.statusCode != 200 && response.statusCode != 201) ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to add location',
      );
    }

    return AddLocationResponse.fromJson(data);
  }

  /// ==============================
  /// FETCH ALL LOCATIONS
  /// ==============================
  Future<List<Location>> fetchLocations() async {
    debugPrint('🟡 FETCHING LOCATIONS');

    final response = await api.get(
      '/api/v1/admin/location',
    );

    debugPrint('📥 STATUS: ${response.statusCode}');
    debugPrint('📥 BODY: ${response.body}');

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 ||
        data['responseSuccessful'] != true) {
      throw Exception(
        data['responseMessage'] ?? 'Failed to fetch locations',
      );
    }

    final List list = data['responseBody'] ?? [];
    return list.map((e) => Location.fromJson(e)).toList();
  }
}