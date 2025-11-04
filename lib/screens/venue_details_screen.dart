import 'package:flutter/material.dart';
import '../models/venue.dart';

class VenueDetailsScreen extends StatelessWidget {
  final Venue venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(venue.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // TODO: Implement favorite
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            Container(
              height: 250,
              child: venue.media != null && venue.media!.isNotEmpty
                  ? PageView.builder(
                      itemCount: venue.media!.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          venue.media![index].url,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, size: 50),
                            );
                          },
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, size: 50),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text(
                            venue.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            ' (${venue.reviewCount})',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        venue.location,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price
                  Text(
                    'PHP ${venue.price.toStringAsFixed(0)} per day',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    venue.description ?? 'No description available',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to booking
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reviews Section
                  const Text(
                    'Reviews',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mock reviews
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            const Text('5.0'),
                            const SizedBox(width: 8),
                            Text(
                              'John Doe',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('Beautiful venue! Perfect for our wedding celebration.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}