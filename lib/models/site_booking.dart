import 'package:cloud_firestore/cloud_firestore.dart';

class SiteBooking {
  final String id;
  final String siteId;
  final String siteName;
  final String userId;
  final DateTime selectedDate;
  final double price;
  final String paymentMethod;
  final String paymentStatus; // pending, paid, failed
  final String? paymentUrl;
  final String? videoUrl;
  final DateTime timestamp;

  SiteBooking({
    required this.id,
    required this.siteId,
    required this.siteName,
    required this.userId,
    required this.selectedDate,
    required this.price,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentUrl,
    this.videoUrl,
    required this.timestamp,
  });

  factory SiteBooking.fromJson(Map<String, dynamic> json) {
    return SiteBooking(
      id: json['id'] ?? '',
      siteId: json['siteId'] ?? '',
      siteName: json['siteName'] ?? '',
      userId: json['userId'] ?? '',
      selectedDate: (json['selectedDate'] as Timestamp).toDate(),
      price: (json['price'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      paymentUrl: json['paymentUrl'],
      videoUrl: json['videoUrl'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'siteId': siteId,
      'siteName': siteName,
      'userId': userId,
      'selectedDate': Timestamp.fromDate(selectedDate),
      'price': price,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentUrl': paymentUrl,
      'videoUrl': videoUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  SiteBooking copyWith({
    String? id,
    String? siteId,
    String? siteName,
    String? userId,
    DateTime? selectedDate,
    double? price,
    String? paymentMethod,
    String? paymentStatus,
    String? paymentUrl,
    String? videoUrl,
    DateTime? timestamp,
  }) {
    return SiteBooking(
      id: id ?? this.id,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      userId: userId ?? this.userId,
      selectedDate: selectedDate ?? this.selectedDate,
      price: price ?? this.price,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}