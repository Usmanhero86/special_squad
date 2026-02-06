import 'package:flutter/cupertino.dart';

import '../models/location_location.dart';
import 'location_service.dart';

class LocationProvider extends ChangeNotifier {
  final LocationService service;

  LocationProvider({required this.service});

  bool isLoading = false;
  bool isFetching = false;
  String? error;
  List<Location> locations = [];

  Future<void> loadLocations() async {
    isFetching = true;
    error = null;
    notifyListeners();

    try {
      locations = await service.fetchLocations();
    } catch (e) {
      error = e.toString();
    } finally {
      isFetching = false;
      notifyListeners();
    }
  }

  Future<bool> addLocation(String name) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await service.addLocation(name);
      locations.insert(0, response.responseBody);
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}