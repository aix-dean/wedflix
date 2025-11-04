class Review {
  final String id;
  final String userId;
  final String venueId;
  final String bookingId;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.venueId,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      venueId: json['venueId'] ?? '',
      bookingId: json['bookingId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'venueId': venueId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}