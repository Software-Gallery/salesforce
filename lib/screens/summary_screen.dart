import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/screens/histori_screen.dart';
import 'package:salesforce/styles/colors.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _selectedFilter = 'Hari Ini';
  int _selectedTab = 0; 
  String _getDateString() {
    final now = DateTime.now();
    
    String format(DateTime date) {
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }

    if (_selectedFilter == 'Hari Ini') {
      return format(now);
    } else if (_selectedFilter == 'Kemarin') {
      return format(now.subtract(const Duration(days: 1)));
    } else if (_selectedFilter == 'Minggu Ini') {
      
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final endOfWeek = startOfWeek.add(const Duration(days: 6));
      return '${format(startOfWeek)} - ${format(endOfWeek)}';
    } else if (_selectedFilter == 'Bulan Ini') {
      
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${months[now.month - 1]} ${now.year}';
    }
    return format(now);
  }

  //
  final List<String> _customers = [
    'Customer A',
    'Customer B',
    'Customer C',
    'Toko Maju Jaya',
    'Warung Sejahtera',
  ];
  String? _selectedCustomer; 


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 1,
      //   leading: IconButton(
      //     icon: const Icon(Icons.menu, color: AppColors.primaryColor, size: 30),
      //     onPressed: () {},
      //   ),
      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: const [
      //       Text(
      //         'My Performance',
      //         style: TextStyle(
      //           color: Colors.black87,
      //           fontWeight: FontWeight.bold,
      //           fontSize: 18,
      //         ),
      //       ),
      //       Text(
      //         'Imron Al Amin - 121',
      //         style: TextStyle(
      //           color: Colors.grey,
      //           fontSize: 14,
      //           fontWeight: FontWeight.normal,
      //         ),
      //       ),
      //     ],
      //   ),
      //   centerTitle: true,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.more_vert, color: AppColors.primaryColor),
      //       onPressed: () {},
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [       
              // Top Tabs
              Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Autocomplete<String>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text == '') {
                              return const Iterable<String>.empty();
                            }
                            return _customers.where((String option) {
                              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            setState(() {
                              _selectedCustomer = selection;
                            });
                          },
                          fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
                            // Handle clear "All Customer" logic
                            if (_selectedCustomer == null && textEditingController.text.isNotEmpty) {
                              // This might happen if user cleared via UI but controller still has text, or logic needs sync
                            }
                            
                            return TextFormField(
                              onTapOutside: (event) {
                                focusNode.unfocus();
                              },
                              controller: textEditingController,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: 'All Customer',
                                hintStyle: const TextStyle(color: Colors.black87),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.primaryColor),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryColor),
                                  onPressed: () {
                                    // Trigger dropdown logic if possible, or just focus
                                    if (focusNode.hasFocus) {
                                      focusNode.unfocus();
                                    } else {
                                      focusNode.requestFocus();
                                    }
                                  },
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  setState(() {
                                    _selectedCustomer = null;
                                  });
                                }
                              },
                            );
                          },
                          optionsViewBuilder: (BuildContext context, AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                child: SizedBox(
                                  width: constraints.maxWidth,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      return InkWell(
                                        onTap: () {
                                          onSelected(option);
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(option),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                    ),
                    SizedBox(height: AppConfig.appSize(context, .01),),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTab == 0
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Performa',
                                style: TextStyle(
                                  color: _selectedTab == 0
                                      ? Colors.white
                                      : AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTab = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedTab == 1
                                    ? AppColors.primaryColor
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Target Pencapaian',
                                style: TextStyle(
                                  color: _selectedTab == 1
                                      ? Colors.white
                                      : AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
        
              // Content Switcher
              // if (_selectedTab == 0) _buildPerformaContent() else _buildTargetContent(),
              if (_selectedTab == 0) _buildTargetContent() else HistoriScreen(),
              
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerformaContent() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: const [
          Icon(Icons.track_changes, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Halaman Target Pencapaian',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );    
  }

  Widget _buildTargetContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Time Filters
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('Hari Ini'),
              const SizedBox(width: 8),
              _buildFilterChip('Kemarin'),
              const SizedBox(width: 8),
              _buildFilterChip('Minggu Ini'),
              const SizedBox(width: 8),
              _buildFilterChip('Bulan Ini'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Date Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _selectedFilter,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getDateString(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Performa Penjualan',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      // const SizedBox(height: 16),

      Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildBentoStat(
              title: 'Penjualan',
              value: 'Rp 0',
              icon: Icons.payments_rounded,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),  
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildBentoStat(
              title: 'Active Outlet',
              value: '0',
              icon: Icons.store_rounded,
              color: Colors.green,
            ),
          ),
          SizedBox(width: 12,),
          Expanded(
            flex: 2,
            child: _buildBentoStat(
              title: 'Avg. SKU',
              value: '0',
              icon: Icons.inventory_2_rounded,
              color: Colors.orange,
            ),
          ),          
        ],
      ),
      // const SizedBox(height: 12),
      // Row(
      //   children: [

      //   ],
      // ),
      
    ],
  ),
),

      ],
    );    
  }

  Widget _buildBentoStat({
    required String title,
    required String value,
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (icon != null)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color?.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                softWrap: true,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold
                ),
              ),              
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.accentColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.accentColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isBoldValue = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
