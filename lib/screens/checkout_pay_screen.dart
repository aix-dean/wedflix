import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../models/site.dart';
import '../models/site_booking.dart';
import '../services/file_upload_service.dart';
import '../services/payment_service.dart';
import '../providers/auth_provider.dart';
import '../providers/app_provider.dart';

class CheckoutPayScreen extends StatefulWidget {
  final Site site;
  final DateTime selectedDate;

  const CheckoutPayScreen({
    super.key,
    required this.site,
    required this.selectedDate,
  });

  @override
  State<CheckoutPayScreen> createState() => _CheckoutPayScreenState();
}

class _CheckoutPayScreenState extends State<CheckoutPayScreen> {
  final FileUploadService _fileUploadService = FileUploadService();
  final PaymentService _paymentService = PaymentService();

  String selectedPaymentMethod = 'GCash';
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? videoUrl;
  bool isProcessingPayment = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Site Information Card
              _buildSiteInfoCard(),

              const SizedBox(height: 24),

              // Dates Section
              _buildDatesSection(),

              const SizedBox(height: 24),

              // Total Price Section
              _buildTotalPriceSection(),

              const SizedBox(height: 24),

              // Content Section
              _buildContentSection(),

              const SizedBox(height: 24),

              // Payment Method Section
              _buildPaymentMethodSection(),

              const SizedBox(height: 24),

              // Price Details Section
              _buildPriceDetailsSection(),

              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSiteInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8DCE0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Site Image
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              widget.site.imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey[300],
                  child: const Icon(Icons.business, size: 32),
                );
              },
            ),
          ),
          const SizedBox(width: 16),

          // Site Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.site.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const SizedBox(height: 8),

                // Rating
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 18,
                      color: Color(0xFF0A0A0A),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.site.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Text(
                  widget.site.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF717375),
                  ),
                ),

                const SizedBox(height: 16),

                // Change Button
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD8DCE0)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Change',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Dates',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_getMonthName(widget.selectedDate.month)} ${widget.selectedDate.day}, ${widget.selectedDate.year}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF717375),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD8DCE0)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Change',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total price',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_getMonthName(widget.selectedDate.month)} ${widget.selectedDate.day}, ${widget.selectedDate.year}',
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF717375),
          ),
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD8DCE0)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Text(
              'Details',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Content',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Please upload a video with a 5:6 aspect ratio in MP4 format. Our system will automatically adjust it to fit the LED screen\'s resolution.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF717375),
          ),
        ),
        const SizedBox(height: 16),

        // Upload Area
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: videoUrl != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 36,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Video uploaded successfully',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ],
                )
              : isUploading
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 8),
                        Text(
                          'Uploading... ${(uploadProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D5F61),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _pickAndUploadVideo,
                          icon: const Icon(
                            Icons.file_upload,
                            size: 36,
                            color: Color(0xFF5D5F61),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Upload your content',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5D5F61),
                          ),
                        ),
                      ],
                    ),
        ),

        const SizedBox(height: 16),

        // Refund Policy
        const Text(
          'This booking is refundable 7 days before your breakdate. Full policy.',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF717375),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment method',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 18),

        // Payment Method Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD8DCE0)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Cash on Delivery Option
              GestureDetector(
                onTap: () => _selectPaymentMethod('Cash on Delivery'),
                child: Row(
                  children: [
                    // Cash on Delivery Logo Placeholder
                    Container(
                      width: 42,
                      height: 26,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text(
                          'COD',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Cash on Delivery',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      selectedPaymentMethod == 'Cash on Delivery'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selectedPaymentMethod == 'Cash on Delivery'
                          ? const Color(0xFFD42F4D)
                          : const Color(0xFF5D5F61),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // GCash Option
              GestureDetector(
                onTap: () => _selectPaymentMethod('GCash'),
                child: Row(
                  children: [
                    // GCash Logo Placeholder
                    Container(
                      width: 42,
                      height: 26,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text(
                          'GCash',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'GCash',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      selectedPaymentMethod == 'GCash'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selectedPaymentMethod == 'GCash'
                          ? const Color(0xFFD42F4D)
                          : const Color(0xFF5D5F61),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Maya Option
              GestureDetector(
                onTap: () => _selectPaymentMethod('Maya'),
                child: Row(
                  children: [
                    // Maya Logo Placeholder
                    Container(
                      width: 42,
                      height: 26,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text(
                          'Maya',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Maya',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      selectedPaymentMethod == 'Maya'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selectedPaymentMethod == 'Maya'
                          ? const Color(0xFFD42F4D)
                          : const Color(0xFF5D5F61),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bank Transfer Option
              GestureDetector(
                onTap: () => _selectPaymentMethod('Bank Transfer'),
                child: Row(
                  children: [
                    // Bank Transfer Logo Placeholder
                    Container(
                      width: 42,
                      height: 26,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text(
                          'Bank',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Bank Transfer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      selectedPaymentMethod == 'Bank Transfer'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selectedPaymentMethod == 'Bank Transfer'
                          ? const Color(0xFFD42F4D)
                          : const Color(0xFF5D5F61),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Xendit Option
              GestureDetector(
                onTap: () => _selectPaymentMethod('Xendit'),
                child: Row(
                  children: [
                    // Xendit Logo Placeholder
                    Container(
                      width: 42,
                      height: 26,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text(
                          'Xendit',
                          style: TextStyle(fontSize: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Xendit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      selectedPaymentMethod == 'Xendit'
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: selectedPaymentMethod == 'Xendit'
                          ? const Color(0xFFD42F4D)
                          : const Color(0xFF5D5F61),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Price details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A0A0A),
          ),
        ),
        const SizedBox(height: 16),

        // Price Breakdown
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1 day x ₱${widget.site.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF717375),
              ),
            ),
            Text(
              '₱${widget.site.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF717375),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total PHP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
                decoration: TextDecoration.underline,
              ),
            ),
            Text(
              '₱${widget.site.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0A0A0A),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        const Text(
          'Price breakdown',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF0A0A0A),
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFD8DCE0)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Confirm and Pay Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessingPayment ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD42F4D),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: isProcessingPayment
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Confirm and pay',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 8),

          // Terms Text
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              text: 'By selecting the button, I agree to the ',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF717375),
              ),
              children: [
                TextSpan(
                  text: 'booking terms.',
                  style: TextStyle(
                    color: Color(0xFF0A0A0A),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadVideo() async {
    try {
      setState(() {
        errorMessage = null;
        isUploading = true;
        uploadProgress = 0.0;
      });

      final file = await _fileUploadService.pickVideoFile();
      if (file == null) {
        setState(() {
          isUploading = false;
        });
        return;
      }

      final userId = context.read<AuthProvider>().currentUser?.uid ?? 'anonymous';
      final downloadUrl = await _fileUploadService.uploadVideoFile(file, userId);

      setState(() {
        videoUrl = downloadUrl;
        isUploading = false;
        uploadProgress = 1.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully')),
      );
    } catch (e) {
      setState(() {
        isUploading = false;
        errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  void _selectPaymentMethod(String method) {
    setState(() {
      selectedPaymentMethod = method;
    });
  }

  Future<void> _processPayment() async {
    if (videoUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a video first')),
      );
      return;
    }

    if (selectedPaymentMethod != 'Xendit') {
      // For other methods, just create booking
      try {
        await _createBooking('pending');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully!')),
        );
        Navigator.of(context).pop(); // Go back to previous screen
      } catch (e) {
        print('Booking error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e')),
        );
      }
    } else {
      try {
        setState(() {
          isProcessingPayment = true;
          errorMessage = null;
        });

        final userEmail = context.read<AuthProvider>().currentUser?.email;
        final invoice = await _paymentService.createInvoice(
          amount: widget.site.price.toInt() < 100 ? 100 : widget.site.price.toInt(),
          description: '${widget.site.name} - ${widget.selectedDate.toString().split(' ')[0]}',
          payerEmail: (userEmail != null && userEmail.contains('@')) ? userEmail : 'test@example.com',
        );

        final paymentUrl = invoice['invoice_url'];
        await _paymentService.openPaymentUrl(paymentUrl);

        // For development, assume payment successful after opening URL
        await _createBooking('paid', paymentUrl: paymentUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful!')),
        );

        Navigator.of(context).pop(); // Go back to previous screen
      } catch (e) {
        setState(() {
          errorMessage = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $e')),
        );
      } finally {
        setState(() {
          isProcessingPayment = false;
        });
      }
    }
  }

  Future<void> _createBooking(String status, {String? paymentUrl}) async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();

      // Parse user display name
      final displayName = user.displayName ?? '';
      final nameParts = displayName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final clientMap = {
        'first_name': firstName,
        'last_name': lastName,
        'email': user.email ?? '',
        'middle_name': '',
        'client_id': user.uid,
      };

      // Extract IDs from site data
      final rawProduct = widget.site.rawData;
      final companyId = rawProduct?['company_id'] ?? 'Pc3HFxYSrwTvTZ8wU84m'; // Default from example
      final productId = rawProduct?['id'] ?? widget.site.id;
      final sellerId = rawProduct?['seller_id'] ?? 'C5Rz6ROQTAegDNMtMXGHzD8CCHU2'; // Default from example

      final bookingData = {
        'company_id': companyId,
        'created': Timestamp.fromDate(now),
        'end_date': Timestamp.fromDate(widget.selectedDate.toUtc()),
        'for_censorship': 0,
        'for_screening': 1,
        'product_id': productId,
        'seller_id': sellerId,
        'start_date': Timestamp.fromDate(widget.selectedDate.toUtc()),
        'updated': Timestamp.fromDate(now),
        'url': videoUrl,
        'client': clientMap,
        'reservation_id': 'RV-${now.millisecondsSinceEpoch}',
      };

      final docRef = await FirebaseFirestore.instance.collection('booking').add(bookingData);

      // Update the document with its auto-generated ID
      await docRef.update({'id': docRef.id});

      print('Attempting to create booking with ID: ${docRef.id}');

      print('Booking created successfully');

      // Update app provider - but AppProvider uses Booking model, not SiteBooking
      // For now, skip or adapt
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}
