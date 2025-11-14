import 'venue.dart';

class Booking {
  final String id;
  final String venueId;
  final String venueName;
  final String userId;
  final String? clientName;
  final String? clientCompanyName;
  final Map<String, dynamic>? client;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;
  final DateTime? created;
  final String? quotationId;
  final String? reservationId;
  final Venue items;
  final Map<String, dynamic>? projectCompliance;
  final Map<String, dynamic>? amounts;

  Booking({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.userId,
    this.clientName,
    this.clientCompanyName,
    this.client,
    this.startDate,
    this.endDate,
    required this.status,
    this.created,
    this.quotationId,
    this.reservationId,
    required this.items,
    this.projectCompliance,
    this.amounts,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      venueId: json['venueId'] ?? '',
      venueName: json['venueName'] ?? '',
      userId: json['userId'] ?? '',
      clientName: json['client_name'],
      clientCompanyName: json['client_company_name'],
      client: json['client'],
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      status: json['status'] ?? 'draft',
      created: json['created'] != null ? DateTime.parse(json['created']) : null,
      quotationId: json['quotation_id'],
      reservationId: json['reservation_id'] ?? 'RV-${DateTime.now().millisecondsSinceEpoch}',
      items: Venue.fromJson(json['items'] ?? {}),
      projectCompliance: json['projectCompliance'],
      amounts: json['amounts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'venueName': venueName,
      'userId': userId,
      'client_name': clientName,
      'client_company_name': clientCompanyName,
      'client': client,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'created': created?.toIso8601String(),
      'quotation_id': quotationId,
      'reservation_id': reservationId,
      'items': items.toJson(),
      'projectCompliance': projectCompliance,
      'amounts': amounts,
    };
  }

  double get totalAmount => amounts?['totalAmount']?.toDouble() ?? 0.0;
}