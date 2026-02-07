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

  Future<bool> updateLocation(String locationId, String newName) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.updateLocation(locationId, newName);

      // Update the location in the list
      final index = locations.indexWhere((loc) => loc.id == locationId);
      if (index != -1) {
        locations[index] = Location(
          id: locationId,
          name: newName,
          address: locations[index].address,
        );
      }

      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteLocation(String locationId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await service.deleteLocation(locationId);

      // Remove the location from the list
      locations.removeWhere((loc) => loc.id == locationId);

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
