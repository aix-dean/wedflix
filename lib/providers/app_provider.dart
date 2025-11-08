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

  // Search state
  DateTime? _selectedWeddingDate;
  String? _selectedOrigin;
  String? _selectedChurch;
  String? _selectedReception;
  bool _isCalendarExpanded = true;

  List<Venue> get venues => _venues;
  List<Booking> get bookings => _bookings;
  User? get currentUser => _currentUser;
  int get currentIndex => _currentIndex;

  // Search getters
  DateTime? get selectedWeddingDate => _selectedWeddingDate;
  String? get selectedOrigin => _selectedOrigin;
  String? get selectedChurch => _selectedChurch;
  String? get selectedReception => _selectedReception;
  bool get isCalendarExpanded => _isCalendarExpanded;

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

  // Search setters
  void setSelectedWeddingDate(DateTime? date) {
    _selectedWeddingDate = date;
    notifyListeners();
  }

  void setSelectedOrigin(String? origin) {
    _selectedOrigin = origin;
    notifyListeners();
  }

  void setSelectedChurch(String? church) {
    _selectedChurch = church;
    notifyListeners();
  }

  void setSelectedReception(String? reception) {
    _selectedReception = reception;
    notifyListeners();
  }

  void setIsCalendarExpanded(bool expanded) {
    _isCalendarExpanded = expanded;
    notifyListeners();
  }
}