import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../data/mock_data.dart';

class AppProvider with ChangeNotifier {
  List<Venue> _venues = mockVenues;
  List<Booking> _bookings = mockBookings;
  User? _currentUser = mockUser;
  int _currentIndex = 0;

  List<Venue> get venues => _venues;
  List<Booking> get bookings => _bookings;
  User? get currentUser => _currentUser;
  int get currentIndex => _currentIndex;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  List<Venue> getVenuesByType(String type) {
    return _venues.where((venue) => venue.type == type).toList();
  }

  Venue? getVenueById(String id) {
    return _venues.firstWhere((venue) => venue.id == id);
  }

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  List<Booking> getUserBookings() {
    if (_currentUser == null) return [];
    return _bookings.where((booking) => booking.userId == _currentUser!.id).toList();
  }
}