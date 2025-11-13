import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/location_service.dart';
import '../services/places_service.dart';
import '../models/venue.dart'; // Wait, no, Place is in places_service
import 'loading_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? activeSelection;
  String originTab = 'Hotel'; // State for origin tab selection

  List<Place> nearbyPlaces = [];
  List<Place> filteredPlaces = [];
  bool isLoadingPlaces = false;
  String? placesError;

  final LocationService locationService = LocationService();
  final PlacesService placesService = PlacesService();

  late TextEditingController originSearchController;
  late TextEditingController churchSearchController;
  late TextEditingController receptionSearchController;

  late DateTime currentMonth;
  late bool _hasInitialized;

  @override
  void initState() {
    super.initState();
    currentMonth = DateTime.now();
    _hasInitialized = false;
    originSearchController = TextEditingController();
    churchSearchController = TextEditingController();
    receptionSearchController = TextEditingController();
  }

  @override
  void dispose() {
    originSearchController.dispose();
    churchSearchController.dispose();
    receptionSearchController.dispose();
    super.dispose();
  }

  void _filterPlaces(String query, String type) {
    if (query.isEmpty) {
      filteredPlaces = nearbyPlaces.where((p) => p.type == type).toList();
    } else {
      filteredPlaces = nearbyPlaces.where((p) => p.type == type && p.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    setState(() {});
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  List<List<int?>> _getCalendarDays(DateTime month) {
    int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    DateTime firstDay = DateTime(month.year, month.month, 1);
    int firstWeekday = firstDay.weekday; // 1 = Monday, 7 = Sunday
    // Labels: S M T W T F S -> Sun Mon Tue Wed Thu Fri Sat
    // weekday 7 (Sun) -> 0, 1 (Mon) -> 1, ..., 6 (Sat) -> 6
    int startOffset = (firstWeekday % 7); // 7 -> 0, 1->1, ..., 6->6
    List<int?> days = [];
    days.addAll(List.filled(startOffset, null));
    for (int d = 1; d <= daysInMonth; d++) {
      days.add(d);
    }
    // Split into weeks
    List<List<int?>> weeks = [];
    for (int i = 0; i < days.length; i += 7) {
      int end = i + 7;
      if (end > days.length) end = days.length;
      List<int?> week = days.sublist(i, end);
      while (week.length < 7) {
        week.add(null);
      }
      weeks.add(week);
    }
    return weeks;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (!_hasInitialized) {
          _hasInitialized = true;
        }
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Tab
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                        child: Text(
                          'Perfect fit for you',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Calendar Card
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: provider.isCalendarExpanded
                              ? Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            provider.setIsCalendarExpanded(false);
                                          },
                                          child: Text(
                                            'When',
                                            style: TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.w500,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),

                                        // Day labels
                                        Row(
                                          children: const [
                                            Expanded(child: Text('S', style: TextStyle(color: Color(0xFF717375)), textAlign: TextAlign.center)),
                                            Expanded(child: Text('M', style: TextStyle(color: Color(0xFF717375)), textAlign: TextAlign.center)),
                                            Expanded(child: Text('T', style: TextStyle(color: Color(0xFF717375)), textAlign: TextAlign.center)),
                                            Expanded(child: Text('W', style: TextStyle(color: Color(0xFF717375)), textAlign: TextAlign.center)),
                                            Expanded(child: Text('T', style: TextStyle(color: Color(0xFF717375)), textAlign: TextAlign.center)),
                                            Expanded(child: Text('F', style: TextStyle(color: Color(0xFF717375)), textAlign: TextAlign.center)),
                                            Expanded(child: Text('S', style: TextStyle(color: Color(0xFF717375)), textAlign: TextAlign.center)),
                                          ],
                                        ),

                                        const SizedBox(height: 16),

                                        // Month title
                                        Text(
                                          '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        const SizedBox(height: 16),

                                        // Calendar grid
                                        Column(
                                          children: _getCalendarDays(currentMonth).map((week) => _buildWeekRow(week, provider)).toList(),
                                        ),
                                        const SizedBox(height: 8),
                                        const Divider(),

                                        const SizedBox(height: 24),

                                        // Next button
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              if (provider.selectedEndDate == null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Please select a date range'),
                                                  ),
                                                );
                                              } else {
                                                provider.setIsCalendarExpanded(false);
                                                _onSelectionChanged('origin');
                                              }
                                            },
                                            child: Container(
                                              width: 132,
                                              padding: const EdgeInsets.only(top: 14, right: 40, bottom: 14, left: 48),
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Next',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : GestureDetector(
                                  onTap: () {
                                    provider.setIsCalendarExpanded(true);
                                  },
                                  
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'When',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF717375),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        provider.selectedStartDate == null ? 'Select' : provider.selectedEndDate == null ? 'Start: ${provider.selectedStartDate!.day}/${provider.selectedStartDate!.month}/${provider.selectedStartDate!.year}' : '${_getMonthName(provider.selectedStartDate!.month)} ${provider.selectedStartDate!.day}, ${provider.selectedStartDate!.year} - ${_getMonthName(provider.selectedStartDate!.month)} ${provider.selectedEndDate!.day}, ${provider.selectedEndDate!.year}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                  /*
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'When',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF717375),
                                        ),
                                      ),
                                      Text(
                                        provider.selectedStartDate == null ? 'Select' : provider.selectedEndDate == null ? 'Start: ${provider.selectedStartDate!.day}/${provider.selectedStartDate!.month}/${provider.selectedStartDate!.year}' : '${provider.selectedStartDate!.day}/${provider.selectedStartDate!.month}/${provider.selectedStartDate!.year} - ${provider.selectedEndDate!.day}/${provider.selectedEndDate!.month}/${provider.selectedEndDate!.year}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),*/
                        ),

                        const SizedBox(height: 18),
                        // Search Fields with collapsible cards
                        _buildSelectionCard(
                          label: 'Lodging',
                          value: provider.selectedOrigin?.name ?? 'Select',
                          type: 'origin',
                          expandedContent: _buildOriginExpandedContent(provider),
                        ),
                        const SizedBox(height: 18),
                        _buildSelectionCard(
                          label: 'Church',
                          value: provider.selectedChurch?.name ?? 'Select',
                          type: 'church',
                          expandedContent: _buildChurchExpandedContent(provider),
                        ),
                        const SizedBox(height: 18),
                        _buildSelectionCard(
                          label: 'Reception',
                          value: provider.selectedReception?.name ?? 'Select',
                          type: 'reception',
                          expandedContent: _buildReceptionExpandedContent(provider),
                        ),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),

                // Bottom bar
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFD8DCE0), width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          provider.setSelectedStartDate(null);
                          provider.setSelectedEndDate(null);
                          provider.setSelectedOrigin(null);
                          provider.setSelectedChurch(null);
                          provider.setSelectedReception(null);
                          provider.setIsCalendarExpanded(true);
                          originSearchController.clear();
                          churchSearchController.clear();
                          receptionSearchController.clear();
                          setState(() {
                            activeSelection = null;
                            originTab = 'Hotel';
                            filteredPlaces = [];
                          });
                        },
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          bool allFilled = provider.selectedStartDate != null &&
                              provider.selectedEndDate != null &&
                              provider.selectedOrigin != null &&
                              provider.selectedChurch != null &&
                              provider.selectedReception != null;
                          if (allFilled) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const LoadingScreen()),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: (provider.selectedStartDate != null &&
                                    provider.selectedEndDate != null &&
                                    provider.selectedOrigin != null &&
                                    provider.selectedChurch != null &&
                                    provider.selectedReception != null)
                                ? const Color(0xFFD42F4D)
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Text(
                                'Search',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onSelectionChanged(String? newSelection) {
    setState(() {
      activeSelection = newSelection;
    });
    if (newSelection != null) {
      _fetchNearbyPlaces(_getTypeForSelection(newSelection));
    } else {
      filteredPlaces = [];
    }
  }

  String _getTypeForSelection(String selection) {
    switch (selection) {
      case 'origin':
        return 'hotel'; // Always fetch hotels for origin
      case 'church':
        return 'church';
      case 'reception':
        return 'reception';
      default:
        return '';
    }
  }

  Future<void> _fetchNearbyPlaces(String type) async {
    if (type.isEmpty) return;
    setState(() {
      isLoadingPlaces = true;
      placesError = null;
      nearbyPlaces = [];
      filteredPlaces = [];
    });
    try {
      final position = await locationService.getCurrentLocation();
      final allPlaces = await placesService.getNearbyPlaces(position.latitude, position.longitude);
      nearbyPlaces = allPlaces.where((p) => p.type == type).toList();
      filteredPlaces = nearbyPlaces;
    } catch (e) {
      placesError = e.toString();
    } finally {
      setState(() {
        isLoadingPlaces = false;
      });
    }
  }

  Widget _buildWeekRow(List<int?> days, AppProvider provider) {
    return Row(
      children: days.map((day) {
        return Expanded(
          child: day == null
              ? const SizedBox()
              : GestureDetector(
                  onTap: () {
                    DateTime tappedDate = DateTime(currentMonth.year, currentMonth.month, day);
                    if (provider.selectedStartDate == null || (provider.selectedStartDate != null && provider.selectedEndDate != null)) {
                      provider.setSelectedStartDate(tappedDate);
                      provider.setSelectedEndDate(null);
                    } else {
                      if (tappedDate.isAfter(provider.selectedStartDate!)) {
                        provider.setSelectedEndDate(tappedDate);
                      } else {
                        provider.setSelectedStartDate(tappedDate);
                        provider.setSelectedEndDate(null);
                      }
                    }
                  },
                  child: Builder(
                    builder: (context) {
                      bool isStart = provider.selectedStartDate?.year == currentMonth.year && provider.selectedStartDate?.month == currentMonth.month && provider.selectedStartDate?.day == day;
                      bool isEnd = provider.selectedEndDate?.year == currentMonth.year && provider.selectedEndDate?.month == currentMonth.month && provider.selectedEndDate?.day == day;
                      bool isBetween = provider.selectedStartDate != null && provider.selectedEndDate != null &&
                        DateTime(currentMonth.year, currentMonth.month, day).isAfter(provider.selectedStartDate!) &&
                        DateTime(currentMonth.year, currentMonth.month, day).isBefore(provider.selectedEndDate!);
                      Color bgColor = isStart || isEnd ? Colors.black : isBetween ? Colors.grey[300]! : Colors.white;
                      Color textColor = isStart || isEnd ? Colors.white : Colors.black;
                      return Container(
                        height: 42,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            day.toString(),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        );
      }).toList(),
    );
  }




  Widget _buildSelectionCard({
    required String label,
    required String value,
    required String type,
    required Widget expandedContent,
  }) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),

          child: activeSelection == type
    ? expandedContent
    : GestureDetector(
        onTap: () {
          _onSelectionChanged(type);
        },
        child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF717375),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            /*: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF717375),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),*/
      ),

          /*
          child: activeSelection == type
              ? expandedContent
              : GestureDetector(
                  onTap: () {
                    _onSelectionChanged(type);
                  },
                  child: Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF717375),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),*/
        );
      },
    );
  }

  Widget _buildOriginExpandedContent(AppProvider provider) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  activeSelection = null;
                });
              },
              child: Text(
                'Lodging',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tab switches
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          originTab = 'Hotel';
                        });
                        provider.setSelectedOrigin(Place(id: 'hotel', name: 'Hotel', lat: 0, lng: 0, address: '', type: 'hotel'));
                        _filterPlaces(originSearchController.text, 'hotel');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: originTab == 'Hotel' ? Colors.white : Colors.transparent,
                          border: originTab == 'Hotel' ? Border.all(color: const Color(0xFFD8DCE0)) : null,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            'Hotel',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          originTab = 'Residence';
                        });
                        provider.setSelectedOrigin(Place(id: 'residence', name: 'Residence', lat: 0, lng: 0, address: '', type: 'residence'));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: originTab == 'Residence' ? Colors.white : Colors.transparent,
                          border: originTab == 'Residence' ? Border.all(color: const Color(0xFFD8DCE0)) : null,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            'Residence',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: originSearchController,
              decoration: InputDecoration(
                hintText: 'Search place',
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFD8DCE0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFD8DCE0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onChanged: (value) {
                _filterPlaces(value, 'hotel');
              },
            ),
            const SizedBox(height: 24),
            if (isLoadingPlaces) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (placesError != null) ...[
              Center(child: Text(placesError!, style: const TextStyle(color: Colors.red))),
            ] else ...[
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              provider.setSelectedOrigin(place);
                              setState(() {
                                activeSelection = null;
                              });
                            },
                            child: Container(
                              width: 124,
                              height: 124,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: index == 0 ? Colors.black : const Color(0xFFD8DCE0),
                                  width: index == 0 ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  place.getPhotoUrl(placesService.apiKey) ?? 'https://via.placeholder.com/124x124?text=No+Image',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.network(
                                    'https://via.placeholder.com/124x124?text=No+Image',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            place.name.length > 15 ? '${place.name.substring(0, 15)}...' : place.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: index == 0 ? FontWeight.w500 : FontWeight.w400,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildChurchExpandedContent(AppProvider provider) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  activeSelection = null;
                });
              },
              child: Text(
                'What church?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: churchSearchController,
              decoration: InputDecoration(
                hintText: 'Search church',
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFD8DCE0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFD8DCE0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onChanged: (value) {
                _filterPlaces(value, 'church');
              },
            ),
            const SizedBox(height: 24),
            if (isLoadingPlaces) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (placesError != null) ...[
              Center(child: Text(placesError!, style: const TextStyle(color: Colors.red))),
            ] else ...[
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              provider.setSelectedChurch(place);
                              setState(() {
                                activeSelection = null;
                              });
                            },
                            child: Container(
                              width: 124,
                              height: 124,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: index == 0 ? Colors.black : const Color(0xFFD8DCE0),
                                  width: index == 0 ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  place.getPhotoUrl(placesService.apiKey) ?? 'https://via.placeholder.com/124x124?text=No+Image',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.network(
                                    'https://via.placeholder.com/124x124?text=No+Image',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            place.name.length > 15 ? '${place.name.substring(0, 15)}...' : place.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: index == 0 ? FontWeight.w500 : FontWeight.w400,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildReceptionExpandedContent(AppProvider provider) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  activeSelection = null;
                });
              },
              child: Text(
                'Reception',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: receptionSearchController,
              decoration: InputDecoration(
                hintText: 'Search reception',
                prefixIcon: Icon(Icons.search, size: 18, color: Colors.black),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFD8DCE0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: const Color(0xFFD8DCE0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.black),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onChanged: (value) {
                _filterPlaces(value, 'reception');
              },
            ),
            const SizedBox(height: 24),
            if (isLoadingPlaces) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (placesError != null) ...[
              Center(child: Text(placesError!, style: const TextStyle(color: Colors.red))),
            ] else ...[
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredPlaces.length,
                  itemBuilder: (context, index) {
                    final place = filteredPlaces[index];
                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              provider.setSelectedReception(place);
                              setState(() {
                                activeSelection = null;
                              });
                            },
                            child: Container(
                              width: 124,
                              height: 124,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: index == 0 ? Colors.black : const Color(0xFFD8DCE0),
                                  width: index == 0 ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  place.getPhotoUrl(placesService.apiKey) ?? 'https://via.placeholder.com/124x124?text=No+Image',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.network(
                                    'https://via.placeholder.com/124x124?text=No+Image',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            place.name.length > 15 ? '${place.name.substring(0, 15)}...' : place.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: index == 0 ? FontWeight.w500 : FontWeight.w400,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}