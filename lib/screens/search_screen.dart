import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String? activeSelection;
  String originTab = 'Hotel'; // State for origin tab selection

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
                    child: provider.isCalendarExpanded
                        ? Column(
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
                                  _buildWeekRow([null, null, 1, 2, 3, 4, 5], provider),
                                  _buildWeekRow([6, 7, 8, 9, 10, 11, 12], provider),
                                  _buildWeekRow([13, 14, 15, 16, 17, 18, 19], provider),
                                  _buildWeekRow([20, 21, 22, 23, 24, 25, 26], provider),
                                  _buildWeekRow([27, 28, 29, 30, 31, null, null], provider),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Next button
                              GestureDetector(
                                onTap: () {
                                  if (provider.selectedWeddingDate == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select a wedding date'),
                                      ),
                                    );
                                  } else {
                                    provider.setIsCalendarExpanded(false);
                                    setState(() {
                                      activeSelection = 'origin';
                                    });
                                  }
                                },
                                child: Container(
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
                              ),
                            ],
                          )
                        : GestureDetector(
                            onTap: () {
                              provider.setIsCalendarExpanded(true);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Wedding Day',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF717375),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      provider.selectedWeddingDate != null
                                          ? '${provider.selectedWeddingDate!.day}/${provider.selectedWeddingDate!.month}/${provider.selectedWeddingDate!.year}'
                                          : 'Select',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.edit,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                  ),

                  // Search Fields (always visible) with their selection cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildTextField('Place of Origin', provider.selectedOrigin ?? 'Select', 'origin'),
                        if (activeSelection == 'origin') ...[
                          const SizedBox(height: 16),
                          _buildOriginSelectionCard(provider),
                        ],
                        const SizedBox(height: 16),
                        _buildTextField('Church', provider.selectedChurch ?? 'Select', 'church'),
                        if (activeSelection == 'church') ...[
                          const SizedBox(height: 16),
                          _buildChurchSelectionCard(),
                        ],
                        const SizedBox(height: 16),
                        _buildTextField('Reception', provider.selectedReception ?? 'Select', 'reception'),
                        if (activeSelection == 'reception') ...[
                          const SizedBox(height: 16),
                          _buildReceptionSelectionCard(),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

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
          ),
        );
      },
    );
  }

  Widget _buildWeekRow(List<int?> days, AppProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        if (day == null) {
          return const SizedBox(width: 40, height: 42);
        }
        final isSelected = provider.selectedWeddingDate?.day == day;
        return GestureDetector(
          onTap: () {
            provider.setSelectedWeddingDate(DateTime(2026, 8, day));
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

  Widget _buildTextField(String label, String value, String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          activeSelection = activeSelection == type ? null : type;
        });
      },
      child: Container(
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
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  activeSelection == type ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginSelectionCard(AppProvider provider) {
    return Container(
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
            'Where are you from?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          // Tab switches
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F7F7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        originTab = 'Hotel';
                      });
                      provider.setSelectedOrigin('Hotel');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: originTab == 'Hotel' ? Colors.white : Colors.transparent,
                        border: originTab == 'Hotel' ? Border.all(color: const Color(0xFFD8DCE0)) : null,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text(
                          'Hotel',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        originTab = 'Residence';
                      });
                      provider.setSelectedOrigin('Residence');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      decoration: BoxDecoration(
                        color: originTab == 'Residence' ? Colors.white : Colors.transparent,
                        border: originTab == 'Residence' ? Border.all(color: const Color(0xFFD8DCE0)) : null,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: Text(
                          'Residence',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8DCE0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: const Color(0xFF717375), size: 18),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Search destinations',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF717375),
                      fontWeight: FontWeight.w500,
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

  Widget _buildChurchSelectionCard() {
    return Container(
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
            'What church?',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8DCE0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: const Color(0xFF717375), size: 18),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Search church',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF717375),
                      fontWeight: FontWeight.w500,
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

  Widget _buildReceptionSelectionCard() {
    return Container(
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
            'Reception',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 24),
          // Search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFD8DCE0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: const Color(0xFF717375), size: 18),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Search destinations',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF717375),
                      fontWeight: FontWeight.w500,
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
}