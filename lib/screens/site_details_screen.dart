import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/site.dart';
import '../models/site_booking.dart';
import 'checkout_pay_screen.dart';

class SiteDetailsScreen extends StatefulWidget {
  final Site site;
  final DateTime selectedDate;

  const SiteDetailsScreen({super.key, required this.site, required this.selectedDate});

  @override
  State<SiteDetailsScreen> createState() => _SiteDetailsScreenState();
}

class _SiteDetailsScreenState extends State<SiteDetailsScreen> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  List<DateTime> _bookedDates = [];
  bool _isLoadingBookings = true;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _fetchBookedDates();
  }

  void _initializeMarkers() {
    markers.add(
      Marker(
        markerId: MarkerId(widget.site.id),
        position: widget.site.position,
        infoWindow: InfoWindow(
          title: widget.site.name,
          snippet: widget.site.location,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed), // Red marker to match app theme
        anchor: const Offset(0.5, 1.0), // Center the marker at the bottom
      ),
    );
  }

  Future<void> _fetchBookedDates() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('site_bookings')
          .where('siteId', isEqualTo: widget.site.id)
          .get();

      final bookedDates = querySnapshot.docs
          .map((doc) => SiteBooking.fromJson(doc.data()))
          .map((booking) => booking.selectedDate)
          .toList();

      setState(() {
        _bookedDates = bookedDates;
        _isLoadingBookings = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBookings = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image carousel
                _buildImageCarousel(),

                // Content sections
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and rating
                      _buildTitleAndRating(),

                      const SizedBox(height: 24),

                      // Features
                      _buildFeatures(),

                      const SizedBox(height: 24),

                      // Description
                      _buildDescription(),

                      const SizedBox(height: 24),

                      // Location
                      _buildLocation(),

                      const SizedBox(height: 24),

                      // Reviews
                      // _buildReviews(),

                      const SizedBox(height: 24),

                      // Availability
                      // _buildAvailability(),

                      const SizedBox(height: 24),

                      // Cancellation policy
                      _buildCancellationPolicy(),

                      const SizedBox(height: 24),

                      // Owner rules
                      _buildOwnerRules(),

                      const SizedBox(height: 24),

                      // Report
                      _buildReport(),

                      // Bottom spacing for bottom bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Top bar
          _buildTopBar(),

          // Bottom bar
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 294,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: widget.site.imageUrls.length,
            itemBuilder: (context, index) {
              return Image.network(
                widget.site.imageUrls[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.business, size: 64),
                  );
                },
              );
            },
          ),

          // Image indicators
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${widget.site.imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 44,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Action buttons
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.ios_share),
                  onPressed: () {
                    // TODO: Implement share
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {
                    // TODO: Implement favorite
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.site.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, size: 18, color: Color(0xFF0A0A0A)),
            const SizedBox(width: 4),
            Text(
              widget.site.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              '·',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () {
                // TODO: Scroll to reviews
              },
              child: Text(
                // '${widget.site.reviewCount} reviews',
                'No Reviews',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0A0A0A),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.site.location,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF717375),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Column(
      children: widget.site.features.map((feature) {
        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(feature.icon, size: 24, color: const Color(0xFF0A0A0A)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      feature.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF717375),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.site.description,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            // TODO: Show more description
          },
          child: const Text(
            'Show more',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0A0A0A),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 18),
        // Google Map
        Container(
          height: 218,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.site.position,
                zoom: 15,
              ),
              markers: markers,
              onMapCreated: (controller) {
                mapController = controller;
              },
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          widget.site.location,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            // TODO: Show more location info
          },
          child: const Text(
            'Show more',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0A0A0A),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  /* Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, size: 18, color: Color(0xFF0A0A0A)),
            const SizedBox(width: 8),
            Text(
              '${widget.site.rating.toStringAsFixed(1)} · ${widget.site.reviewCount} reviews',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // Sample reviews
        if (widget.site.reviews.isNotEmpty) ...[
          ...widget.site.reviews.map((review) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFD8DCE0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.reviewText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // TODO: Show more review
                    },
                    child: const Text(
                      'Show more',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      // Avatar placeholder
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(Icons.person),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            review.reviewerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                          Text(
                            review.timeAgo,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF717375),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF0A0A0A)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'Show all ${widget.site.reviewCount} reviews',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF0A0A0A),
            ),
          ),
        ),
      ],
    );
  }*/

  /* Widget _buildAvailability() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 8),
        if (_isLoadingBookings)
          const Text(
            'Loading...',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF717375),
            ),
          )
        else if (_bookedDates.isEmpty)
          const Text(
            'Available',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF717375),
            ),
          )
        else
          Text(
            'Booked: ${_bookedDates.map((date) => DateFormat('MMM d').format(date)).join(', ')}',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF717375),
            ),
          ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Select dates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF0A0A0A)),
          ],
        ),
      ],
    );
  } */

  Widget _buildCancellationPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cancellation policy',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Free cancellation before Apr 1, 2026.\nReview the Host\'s full cancellation policy which applies even if you cancel for other reasons.',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF717375),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Show more',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
                decoration: TextDecoration.underline,
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF0A0A0A)),
          ],
        ),
      ],
    );
  }

  Widget _buildOwnerRules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Owner\'s rules',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'No profanity in the videos',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF717375),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Show more',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildReport() {
    return Row(
      children: [
        const Icon(Icons.flag, size: 18, color: Color(0xFF0A0A0A)),
        const SizedBox(width: 8),
        const Text(
          'Report this listing',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFD8DCE0)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₱${widget.site.price.toStringAsFixed(0)} day',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  Text(
                    DateFormat('MMM d, y').format(widget.selectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0A0A0A),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPayScreen(
                      site: widget.site,
                      selectedDate: widget.selectedDate,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD42F4D),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                'Book',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

