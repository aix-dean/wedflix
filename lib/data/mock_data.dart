import '../models/venue.dart';
import '../models/booking.dart';
import '../models/review.dart';
import '../models/user.dart';
import '../models/company.dart';

final List<Venue> mockVenues = [
  Venue(
    id: '1',
    iD: 'venue_1',
    name: 'Manila Cathedral',
    type: 'church',
    price: 50000,
    location: 'Manila',
    siteCode: 'MC001',
    description: 'Beautiful historic cathedral perfect for weddings',
    rating: 4.8,
    reviewCount: 25,
    availability: [
      {
        'startDate': DateTime(2025, 6, 1).toIso8601String(),
        'endDate': DateTime(2025, 6, 30).toIso8601String(),
      }
    ],
    media: [
      ProductMedia(
        url: 'https://picsum.photos/400/300?random=1',
        distance: '0.5km',
        type: 'image',
        isVideo: false,
      ),
      ProductMedia(
        url: 'https://picsum.photos/400/300?random=2',
        distance: '0.5km',
        type: 'image',
        isVideo: false,
      ),
    ],
    specsRental: ProductSpecsRental(
      location: 'Intramuros, Manila',
      trafficCount: 50000,
      audienceTypes: ['General Public'],
    ),
  ),
  Venue(
    id: '2',
    iD: 'venue_2',
    name: 'Grand Hyatt Manila',
    type: 'hotel',
    price: 150000,
    location: 'Makati',
    siteCode: 'GH001',
    description: 'Luxury hotel with stunning ballroom',
    rating: 4.9,
    reviewCount: 45,
    availability: [
      {
        'startDate': DateTime(2025, 7, 1).toIso8601String(),
        'endDate': DateTime(2025, 7, 31).toIso8601String(),
      }
    ],
    media: [
      ProductMedia(
        url: 'https://picsum.photos/400/300?random=3',
        distance: '1.2km',
        type: 'image',
        isVideo: false,
      ),
    ],
    specsRental: ProductSpecsRental(
      location: 'Paseo de Roxas, Makati',
      trafficCount: 80000,
      height: 20,
      width: 30,
      audienceTypes: ['Business Professionals'],
    ),
  ),
  Venue(
    id: '3',
    iD: 'venue_3',
    name: 'Casa Ibarra',
    type: 'reception',
    price: 80000,
    location: 'Quezon City',
    siteCode: 'CI001',
    description: 'Elegant reception venue with garden',
    rating: 4.7,
    reviewCount: 18,
    availability: [
      {
        'startDate': DateTime(2025, 8, 1).toIso8601String(),
        'endDate': DateTime(2025, 8, 31).toIso8601String(),
      }
    ],
    media: [
      ProductMedia(
        url: 'https://picsum.photos/400/300?random=4',
        distance: '2.1km',
        type: 'image',
        isVideo: false,
      ),
    ],
    specsRental: ProductSpecsRental(
      location: 'Timog Avenue, Quezon City',
      trafficCount: 30000,
      audienceTypes: ['Families'],
    ),
  ),
];

final User mockUser = User(
  id: 'user_1',
  email: 'john.doe@example.com',
  displayName: 'John Doe',
  phone: '+63 912 345 6789',
  profileImage: 'https://picsum.photos/200/200?random=user',
  companyId: 'company_1',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

final CompanyData mockCompany = CompanyData(
  companyId: 'company_1',
  name: 'WedFlix Events',
  address: {
    'street': '123 Main St',
    'city': 'Manila',
    'province': 'Metro Manila',
  },
  email: 'info@wedflix.com',
  phone: '+63 2 123 4567',
  logo: 'https://picsum.photos/200/200?random=logo',
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
  createdBy: 'admin',
  updatedBy: 'admin',
);

final List<Booking> mockBookings = [
  Booking(
    id: 'booking_1',
    venueId: '1',
    venueName: 'Manila Cathedral',
    userId: 'user_1',
    clientName: 'John Doe',
    clientCompanyName: 'ABC Corp',
    startDate: DateTime(2025, 6, 15),
    endDate: DateTime(2025, 6, 15),
    status: 'confirmed',
    created: DateTime.now(),
    reservationId: 'RV-001',
    items: mockVenues[0],
  ),
];

final List<Review> mockReviews = [
  Review(
    id: 'review_1',
    userId: 'user_1',
    venueId: '1',
    bookingId: 'booking_1',
    rating: 5.0,
    comment: 'Absolutely beautiful venue! Perfect for our wedding.',
    createdAt: DateTime.now(),
  ),
];