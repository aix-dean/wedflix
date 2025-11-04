import 'package:flutter/material.dart';

class DateSelectionScreen extends StatefulWidget {
  const DateSelectionScreen({super.key});

  @override
  State<DateSelectionScreen> createState() => _DateSelectionScreenState();
}

class _DateSelectionScreenState extends State<DateSelectionScreen> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Tab
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    child: const Text(
                      'Perfect fit for you',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Calendar Card
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'When is the big day?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Day labels
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('S', style: TextStyle(color: Color(0xFF717375))),
                      Text('M', style: TextStyle(color: Color(0xFF717375))),
                      Text('T', style: TextStyle(color: Color(0xFF717375))),
                      Text('W', style: TextStyle(color: Color(0xFF717375))),
                      Text('T', style: TextStyle(color: Color(0xFF717375))),
                      Text('F', style: TextStyle(color: Color(0xFF717375))),
                      Text('S', style: TextStyle(color: Color(0xFF717375))),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Month title
                  const Text(
                    'August 2026',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Calendar grid (simplified)
                  Column(
                    children: [
                      _buildWeekRow([null, null, 1, 2, 3, 4, 5]),
                      _buildWeekRow([6, 7, 8, 9, 10, 11, 12]),
                      _buildWeekRow([13, 14, 15, 16, 17, 18, 19]),
                      _buildWeekRow([20, 21, 22, 23, 24, 25, 26]),
                      _buildWeekRow([27, 28, 29, 30, 31, null, null]),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Next button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Form fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildTextField('Place of Origin', 'Select'),
                  const SizedBox(height: 16),
                  _buildTextField('Church', 'Select'),
                  const SizedBox(height: 16),
                  _buildTextField('Reception', 'Select'),
                ],
              ),
            ),

            const Spacer(),

            // Bottom bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFD8DCE0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'Clear all',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD42F4D),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  Widget _buildWeekRow(List<int?> days) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        if (day == null) {
          return const SizedBox(width: 40, height: 42);
        }
        final isSelected = selectedDate?.day == day;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedDate = DateTime(2026, 8, day);
            });
          },
          child: Container(
            width: 40,
            height: 42,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : (day == 15 ? const Color(0xFF4E0916) : Colors.black),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD8DCE0)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF717375),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}