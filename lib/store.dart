import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class PackioStore extends ChangeNotifier {
  static const _tripsKey = 'packio_trips_v1';
  static const _darkKey = 'packio_dark_v1';

  final List<Trip> trips = [];
  bool ready = false;
  bool darkMode = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool(_darkKey) ?? false;

    final raw = prefs.getString(_tripsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        trips
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((e) => Trip.fromJson(Map<String, dynamic>.from(e))),
          );
      } catch (_) {
        trips.clear();
      }
    }

    ready = true;
    notifyListeners();
  }

  Future<void> _saveTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tripsKey,
      jsonEncode(trips.map((e) => e.toJson()).toList()),
    );
  }

  Future<void> addTrip(Trip trip) async {
    trips.add(trip);
    _sort();
    await _saveTrips();
    notifyListeners();
  }

  Future<void> updateTrip(Trip trip) async {
    final index = trips.indexWhere((e) => e.id == trip.id);
    if (index == -1) return;
    trips[index] = trip;
    _sort();
    await _saveTrips();
    notifyListeners();
  }

  Future<void> deleteTrip(String id) async {
    trips.removeWhere((e) => e.id == id);
    await _saveTrips();
    notifyListeners();
  }

  Future<void> duplicateTrip(Trip trip) async {
    trips.add(trip.duplicate());
    _sort();
    await _saveTrips();
    notifyListeners();
  }

  Future<void> togglePacked(Trip trip, PackItem item) async {
    item.packed = !item.packed;
    await _saveTrips();
    notifyListeners();
  }

  Future<void> addItem(Trip trip, PackItem item) async {
    trip.items.add(item);
    await _saveTrips();
    notifyListeners();
  }

  Future<void> updateItem(Trip trip, PackItem item) async {
    final index = trip.items.indexWhere((e) => e.id == item.id);
    if (index == -1) return;
    trip.items[index] = item;
    await _saveTrips();
    notifyListeners();
  }

  Future<void> deleteItem(Trip trip, String itemId) async {
    trip.items.removeWhere((e) => e.id == itemId);
    await _saveTrips();
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkKey, value);
    notifyListeners();
  }

  Future<void> resetAll() async {
    trips.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripsKey);
    notifyListeners();
  }

  Trip? get nextTrip {
    if (trips.isEmpty) return null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final upcoming = trips.where((trip) {
      final end = DateTime(
        trip.endDate.year,
        trip.endDate.month,
        trip.endDate.day,
      );
      return !end.isBefore(today);
    }).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    return upcoming.isEmpty ? null : upcoming.first;
  }

  int get totalItems => trips.fold(0, (sum, t) => sum + t.items.length);

  int get packedItems => trips.fold(
        0,
        (sum, t) => sum + t.items.where((e) => e.packed).length,
      );

  int get essentialItems => trips.fold(
        0,
        (sum, t) => sum + t.items.where((e) => e.essential).length,
      );

  void _sort() {
    trips.sort((a, b) => a.startDate.compareTo(b.startDate));
  }
}
