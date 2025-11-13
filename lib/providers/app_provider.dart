import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../models/booking.dart';
import '../models/user.dart';
import '../data/mock_data.dart';
import '../services/places_service.dart';

class AppProvider with ChangeNotifier {
  List<Venue> _venues = mockVenues;
  List<Booking> _bookings = mockBookings;
  User? _currentUser = mockUser;
  int _currentIndex = 0;
  bool _hasInboxNotifications = true; // Set to true for demo, should be based on actual notifications

  // Search state
  DateTime? _selectedWeddingDate;
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  Place? _selectedOrigin;
  Place? _selectedChurch;
  Place? _selectedReception;
  bool _isCalendarExpanded = true;

  List<Venue> get venues => _venues;
  List<Booking> get bookings => _bookings;
  User? get currentUser => _currentUser;
  int get currentIndex => _currentIndex;
  bool get hasInboxNotifications => _hasInboxNotifications;

  // Search getters
  DateTime? get selectedWeddingDate => _selectedWeddingDate;
  Place? get selectedOrigin => _selectedOrigin;
  Place? get selectedChurch => _selectedChurch;
  Place? get selectedReception => _selectedReception;
  bool get isCalendarExpanded => _isCalendarExpanded;
  DateTime? get selectedStartDate => _selectedStartDate;
  DateTime? get selectedEndDate => _selectedEndDate;

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
  void setSelectedStartDate(DateTime? date) {
    _selectedStartDate = date;
    notifyListeners();
  }

  void setSelectedEndDate(DateTime? date) {
    _selectedEndDate = date;
    notifyListeners();
  }

  void setSelectedOrigin(Place? origin) {
    _selectedOrigin = origin;
    notifyListeners();
  }

  void setSelectedChurch(Place? church) {
    _selectedChurch = church;
    notifyListeners();
  }

  void setSelectedReception(Place? reception) {
    _selectedReception = reception;
    notifyListeners();
  }

  void setIsCalendarExpanded(bool expanded) {
    _isCalendarExpanded = expanded;
    notifyListeners();
  }
}