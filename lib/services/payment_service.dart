import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PaymentService {
  static const String _baseUrl = 'https://api.xendit.co/v2';
  static String get _apiKey => dotenv.env['XENDIT_API_KEY'] ?? '';

  /// Create Xendit invoice
  Future<Map<String, dynamic>> createInvoice({
    required int amount,
    required String description,
    String? payerEmail,
    String? successRedirectUrl,
    String? failureRedirectUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/invoices'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'external_id': 'wedflix-${DateTime.now().millisecondsSinceEpoch}',
          'amount': amount,
          'description': description,
          'payer_email': payerEmail ?? 'test@example.com',
          'success_redirect_url': successRedirectUrl ?? 'wedflix://success',
          'failure_redirect_url': failureRedirectUrl ?? 'wedflix://failure',
          'currency': 'PHP',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create invoice: ${response.body}');
      }
    } catch (e) {
      throw Exception('Payment service error: $e');
    }
  }

  /// Get invoice status
  Future<Map<String, dynamic>> getInvoiceStatus(String invoiceId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/invoices/$invoiceId'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:'))}',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get invoice status: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get invoice status: $e');
    }
  }

  /// Open payment URL in browser
  Future<void> openPaymentUrl(String url) async {
    try {
      print('Attempting to launch payment URL: $url');
      final Uri uri = Uri.parse(url);
      
      final canLaunch = await canLaunchUrl(uri);
      print('canLaunchUrl result: $canLaunch');
      
      if (canLaunch) {
        print('Launching URL in external application');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('URL launched successfully');
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      print('Error in openPaymentUrl: $e');
      throw Exception('Failed to open payment URL: $e');
    }
  }
}