import 'package:flutter/material.dart';
import '../models/venue.dart';
import '../screens/venue_details_screen.dart';

class VenueCard extends StatelessWidget {
  final Venue venue;

  const VenueCard({super.key, required this.venue});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VenueDetailsScreen(venue: venue),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Venue Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(
                    venue.media?.isNotEmpty == true
                        ? venue.media!.first.url
                        : 'https://picsum.photos/400/200?random=${venue.id}',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Venue Name and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          venue.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          Text(
                            venue.rating.toString(),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            ' (${venue.reviewCount})',
                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        venue.location,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Price
                  Text(
                    'PHP ${venue.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.pink,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Description
                  Text(
                    venue.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
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