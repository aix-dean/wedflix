import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../models/site.dart';
import '../services/file_upload_service.dart';
import '../services/payment_service.dart';
import '../providers/auth_provider.dart';
import 'loading_screen.dart';
import 'processed_screen.dart';

class CheckoutPayScreen extends StatefulWidget {
  final Site site;
  final DateTime startDate;
  final DateTime endDate;

  const CheckoutPayScreen({
    super.key,
    required this.site,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<CheckoutPayScreen> createState() => _CheckoutPayScreenState();
}

class _CheckoutPayScreenState extends State<CheckoutPayScreen> {
  final FileUploadService _fileUploadService = FileUploadService();

  String selectedPaymentMethod = 'GCash';
  bool isUploading = false;
  double uploadProgress = 0.0;
  String? videoUrl;
  bool isProcessingPayment = false;
  String? errorMessage;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm and Pay'),
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
              // Big Card for site to content
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD8DCE0)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildSiteInfoContent(),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFD8DCE0)),
                    const SizedBox(height: 8),
                    _buildDatesContent(),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFD8DCE0)),
                    const SizedBox(height: 8),
                    _buildTotalPriceContent(),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFD8DCE0)),
                    _buildContentContent(),
                  ],
                ),
              ),

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

  Widget _buildSiteInfoContent() {
    return Row(
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatesContent() {
    final dateRangeText = widget.startDate == widget.endDate
        ? '${_getMonthName(widget.startDate.month)} ${widget.startDate.day}, ${widget.startDate.year}'
        : '${_getMonthName(widget.startDate.month)} ${widget.startDate.day} - ${_getMonthName(widget.endDate.month)} ${widget.endDate.day}, ${widget.endDate.year}';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
                dateRangeText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717375),
                ),
              ),
            ],
          ),
        ),
        Container(
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
      ],
    );
  }

  Widget _buildTotalPriceContent() {
    final numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
    final totalPrice = widget.site.price * numberOfDays;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
                '₱${totalPrice >= 1000 ? NumberFormat('#,###').format(totalPrice) : totalPrice.toStringAsFixed(0)} for $numberOfDays ${numberOfDays == 1 ? 'day' : 'days'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717375),
                ),
              ),
            ],
          ),
        ),
        Container(
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
      ],
    );
  }

  Widget _buildContentContent() {
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
        RichText(
          text: const TextSpan(
            text: 'Please upload a video with a ',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF717375),
            ),
            children: [
              TextSpan(
                text: '5:6 aspect ratio',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' in '),
              TextSpan(
                text: 'MP4',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' format. Our system will automatically adjust it to fit the LED screen\'s resolution.'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Upload Area - Optimized with Chewie for better controls and responsive layout
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AspectRatio(
            aspectRatio: 5 / 6, // Maintain 5:6 aspect ratio for portrait video
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: videoUrl != null
                  ? _isVideoInitialized && _chewieController != null
                      ? Chewie(
                          controller: _chewieController!,
                        )
                      : const Center(child: CircularProgressIndicator())
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
          ),
        ),
// Change button when video is uploaded
if (videoUrl != null)
  Row(
    children: [
      const Spacer(),
      GestureDetector(
        onTap: _showChangeContentDialog,
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
        
        const SizedBox(height: 16),
        
        const Divider(color: Color(0xFFD8DCE0)),
        
        const SizedBox(height: 16),
        
        // Refund Policy
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 16),
          child: RichText(
            text: const TextSpan(
              text: 'This booking is refundable 3 days before your breakdate. ',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF717375),
              ),
              children: [
                TextSpan(
                  text: 'Full policy.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodContent() {
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

        // Payment Method Options
        Column(
          children: [
            // GCash Option
            GestureDetector(
              onTap: () => _selectPaymentMethod('GCash'),
              child: Row(
                children: [
                  // GCash Icon
                  Container(
                    width: 42,
                    height: 26,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.account_balance_wallet,
                        size: 20,
                        color: Colors.blue,
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

            // 1332 Option
            GestureDetector(
              onTap: () => _selectPaymentMethod('1332'),
              child: Row(
                children: [
                  // 1332 Icon
                  Container(
                    width: 42,
                    height: 26,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Text(
                        'Credit/Debit Card',
                        style: TextStyle(fontSize: 10, color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Credit/Debit Card',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    selectedPaymentMethod == 'Credit/Debit Card'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: selectedPaymentMethod == 'Credit/Debit Card'
                        ? const Color(0xFFD42F4D)
                        : const Color(0xFF5D5F61),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // More options
            Row(
              children: [
                const Text(
                  'More options',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: const Color(0xFF5D5F61),
                ),
              ],
            ),

          ],
        ),
      ],
    );
  }

  Widget _buildPriceDetailsContent() {
    final numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
    final totalPrice = widget.site.price * numberOfDays;

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
              '$numberOfDays ${numberOfDays == 1 ? 'day' : 'days'} x ₱${widget.site.price >= 1000 ? NumberFormat('#,###').format(widget.site.price) : widget.site.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF717375),
              ),
            ),
            Text(
              '₱${totalPrice >= 1000 ? NumberFormat('#,###').format(totalPrice) : totalPrice.toStringAsFixed(0)}',
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
              '₱${totalPrice >= 1000 ? NumberFormat('#,###').format(totalPrice) : totalPrice.toStringAsFixed(0)}',
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

  Widget _buildDatesSection() {
    final dateRangeText = widget.startDate == widget.endDate
        ? '${_getMonthName(widget.startDate.month)} ${widget.startDate.day}, ${widget.startDate.year}'
        : '${_getMonthName(widget.startDate.month)} ${widget.startDate.day} - ${_getMonthName(widget.endDate.month)} ${widget.endDate.day}, ${widget.endDate.year}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8DCE0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
            dateRangeText,
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
      ),
    );
  }

  Widget _buildTotalPriceSection() {
    final numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
    final totalPrice = widget.site.price * numberOfDays;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8DCE0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
            '₱${totalPrice >= 1000 ? NumberFormat('#,###').format(totalPrice) : totalPrice.toStringAsFixed(0)} for $numberOfDays ${numberOfDays == 1 ? 'day' : 'days'}',
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
      ),
    );
  }

  Widget _buildContentSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8DCE0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
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
          RichText(
            text: const TextSpan(
              text: 'Please upload a video with a ',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF717375),
              ),
              children: [
                TextSpan(
                  text: '5:6 aspect ratio',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' in '),
                TextSpan(
                  text: 'MP4',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: ' format. Our system will automatically adjust it to fit the LED screen\'s resolution.'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Upload Area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(12),
              ),
            child: videoUrl != null
                ? _isVideoInitialized
                    ? Stack(
                        children: [
                          VideoPlayer(_videoController!),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (_videoController!.value.isPlaying) {
                                          _videoController!.pause();
                                        } else {
                                          _videoController!.play();
                                        }
                                      });
                                    },
                                  ),
                                  Expanded(
                                    child: VideoProgressIndicator(
                                      _videoController!,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                        playedColor: Colors.red,
                                        bufferedColor: Colors.white,
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator()
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
          ),

          const SizedBox(height: 16),
  
          const Divider(color: Color(0xFFD8DCE0)),
  
          // Refund Policy
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: RichText(
              text: const TextSpan(
                text: 'This booking is refundable 3 days before your breakdate. ',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF717375),
                ),
                children: [
                  TextSpan(
                    text: 'Full policy.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
              // GCash Option
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: GestureDetector(
                  onTap: () => _selectPaymentMethod('GCash'),
                  child: Row(
                    children: [
                      // GCash Icon
                      Container(
                        width: 42,
                        height: 26,
                        child: Image.asset(
                          'assets/payment_icons/a822b87c174252ab4fe0522615f8fd7836921421.png',
                          fit: BoxFit.cover,
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
              ),

              const Divider(color: Color(0xFFD8DCE0)),

              // 1332 Option
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: GestureDetector(
                  onTap: () => _selectPaymentMethod('Credit/Debit Card'),
                  child: Row(
                    children: [
                      // 1332 Icon
                      Container(
                        width: 42,
                        height: 26,
                        child: Image.asset(
                          'assets/payment_icons/mastercard.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Credit/Debit Card',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF0A0A0A),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        selectedPaymentMethod == '1332'
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: selectedPaymentMethod == '1332'
                            ? const Color(0xFFD42F4D)
                            : const Color(0xFF5D5F61),
                      ),
                    ],
                  ),
                ),
              ),

              const Divider(color: Color(0xFFD8DCE0)),

              // Maya Option
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: GestureDetector(
                  onTap: () => _selectPaymentMethod('Maya'),
                  child: Row(
                    children: [
                      // Maya Icon
                      Container(
                        width: 42,
                        height: 26,
                        child: Image.asset(
                          'assets/payment_icons/maya.png',
                          fit: BoxFit.cover,
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
              ),

            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetailsSection() {
    final numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
    final totalPrice = widget.site.price * numberOfDays;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
                '$numberOfDays ${numberOfDays == 1 ? 'day' : 'days'} x ₱${widget.site.price >= 1000 ? NumberFormat('#,###').format(widget.site.price) : widget.site.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717375),
                ),
              ),
              Text(
                '₱${totalPrice >= 1000 ? NumberFormat('#,###').format(totalPrice) : totalPrice.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF717375),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
  
          const Divider(color: Color(0xFFD8DCE0)),
  
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
                '₱${totalPrice >= 1000 ? NumberFormat('#,###').format(totalPrice) : totalPrice.toStringAsFixed(0)}',
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
      ),
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
        // Dispose previous controllers
        _chewieController?.dispose();
        _videoController?.dispose();
        _videoController = null;
        _chewieController = null;
        _isVideoInitialized = false;
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

      // Initialize video controller
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl!));
      await _videoController!.initialize();

      // Initialize Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        aspectRatio: 5 / 6, // 5:6 aspect ratio for portrait video
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      setState(() {
        _isVideoInitialized = true;
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

    // For all payment methods, create pending booking
    try {
      await _createBooking('pending');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking created successfully!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoadingScreen(nextScreen: const ProcessedScreen())),
      );
    } catch (e) {
      print('Booking error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }
  void _showChangeContentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Content'),
          content: const Text('Are you sure you want to replace your current content?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickAndUploadVideo();
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createBooking(String status, {String? paymentUrl}) async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();

      // Parse user display name
      final displayName = user.displayName ?? '';

      final clientMap = {
        'email': user.email ?? '',
        'id': user.uid,
        'name': displayName,
      };

      // Extract IDs from site data
      final rawProduct = widget.site.rawData;
      final companyId = rawProduct?['company_id'] ?? 'Pc3HFxYSrwTvTZ8wU84m'; // Default from example
      final productId = rawProduct?['id'] ?? widget.site.id;
      final sellerId = widget.site.sellerId ?? rawProduct?['seller_id'] ?? rawProduct?['company_id'] ?? 'C5Rz6ROQTAegDNMtMXGHzD8CCHU2'; // Use site.sellerId, then rawData, then company_id as fallback

      // Calculate amounts
      final numberOfDays = widget.endDate.difference(widget.startDate).inDays + 1;
      final totalPrice = widget.site.price * numberOfDays;
      const taxRate = 0.12;
      final taxAmount = totalPrice * taxRate;
      final netAmount = totalPrice - taxAmount;
      final amounts = {
        'totalAmount': totalPrice,
        'taxRate': taxRate,
        'taxAmount': taxAmount,
        'netAmount': netAmount,
      };

      final bookingData = {
        'company_id': companyId,
        'created': Timestamp.fromDate(now),
        'end_date': Timestamp.fromDate(widget.endDate.toUtc()),
        'for_censorship': 0,
        'for_screening': 1,
        'product_id': productId,
        'seller_id': sellerId,
        'start_date': Timestamp.fromDate(widget.startDate.toUtc()),
        'updated': Timestamp.fromDate(now),
        'url': videoUrl,
        'client': clientMap,
        'reservation_id': 'RV-${now.millisecondsSinceEpoch}',
        'amounts': amounts,
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
