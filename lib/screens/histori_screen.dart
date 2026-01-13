import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/helpers/column_with_seprator.dart';
import 'package:salesforce/models/customer_item.dart';
import 'package:salesforce/models/rute_item.dart';
import 'package:salesforce/models/trn_sales_order_header.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/screens/view_kunjungan.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class HistoriScreen extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final CustomerItem customer;
  final VoidCallback onPopulate;
  const HistoriScreen({super.key, required this.startDate, required this.endDate, required this.customer, required this.onPopulate()});

  @override
  State<HistoriScreen> createState() => _HistoriScreenState();
}

class _HistoriScreenState extends State<HistoriScreen> {
  bool isTrnLoad = true;
  String tglaktif = '2025-12-31';
  String _selectedFilter = '';  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final ruteProvider = Provider.of<RuteProvider>(context, listen: false);
        // DateFormat('yyyy-MM-dd').format(widget.endDate!)
        await ruteProvider.populateHistoriFromApi(DateFormat('yyyy-MM-dd').format(widget.startDate), DateFormat('yyyy-MM-dd').format(widget.endDate), widget.customer.id).then((value) async {
          await Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
              isTrnLoad = false;
            });
          });
        });     
        // final trnHeaderProvider = Provider.of<TrmSalesOrderHeaderProvider>(context, listen: false);
        // await trnHeaderProvider.populateFromApi().then((value) async {
        //   await Future.delayed(Duration(milliseconds: 500)).then((value) {
        //     setState(() {
        //       isTrnLoad = false; 
        //     });
        //   });
        // });     
      } catch (e) {
        print(e.toString());
      }
    });
  }

  Future<void> loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final prefstglaktif = await prefs.getString('tglaktif') ?? '';
    setState(() {
      tglaktif = prefstglaktif;
    });
  }  
  
  @override
  Widget build(BuildContext context) {
    return Consumer<RuteProvider>(
      builder: (context, ruteProvider, child) {
        // return Scaffold(
        //   appBar: AppBar(
        //     iconTheme: IconThemeData(color: Colors.white), 
        //     backgroundColor: AppColors.primaryColor,
        //     elevation: 0,
        //     centerTitle: true,
        //     title: Container(
        //       child: AppText(
        //         text: 'History',
        //         fontWeight: FontWeight.bold,
        //         fontSize: AppConfig.appSize(context, .016),
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
          return SingleChildScrollView(
            child: Column(
              children: [
                // SizedBox(height: AppConfig.appSize(context, .02),), 
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        // padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            _buildFilterChip('DRAFT', AppColors.accentColor),
                            const SizedBox(width: 6),
                            _buildFilterChip('POSTED', Colors.amber),
                            const SizedBox(width: 6),
                            _buildFilterChip('FINISH', AppColors.secondaryColor),
                          ],
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet<void>(
                            backgroundColor: Colors.white,
                            showDragHandle: true,
                            useSafeArea: true,
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return DraggableScrollableSheet(
                                snapSizes: [0.5,0.9],
                                initialChildSize: 0.9,
                                expand: false,
                                builder: (_, controller) => _SortingSheetContent(
                                  selectedStatus: ruteProvider.currentSortHistory,
                                  controller: controller,), 
                              );
                            },
                          );  
                        },                              
                        child: Container(
                          // width: AppConfig.appSize(context, .03),
                          height: AppConfig.appSize(context, .03),
                          padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .012), vertical: AppConfig.appSize(context, .006)),
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.circular(AppConfig.appSize(context, .01)),
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300)
                            // boxShadow: [
                            //   BoxShadow(
                            //     color: Colors.black.withOpacity(0.08),
                            //     blurRadius: 10,
                            //     offset: const Offset(0, 4),
                            //   ),
                            // ],                          
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Sort',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppConfig.appSize(context, .011),
                                ),
                              ),
                              SizedBox(width: AppConfig.appSize(context, .01),),
                              SvgPicture.asset(
                                'assets/icons/filter.svg',
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ), 
                SkeletonLoader(
                  isLoading: isTrnLoad,
                  skeleton: Skeletonizer(
                    effect: ShimmerEffect(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.white,
                      duration: Duration(milliseconds: 1200),
                    ),
                    child: Column(
                      children: getChildrenWithSeperator(
                        addToLastChild: true,
                        widgets: ruteList.map((e) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                            ),
                            width: double.maxFinite,
                            // child: Skeleton.leaf(child: visitCard(e,))
                            child: visitCard(e,),
                          );
                        }).toList(),
                        seperator: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                          ),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                      ),
                    ),
                  ), 
                  child: 
                  ruteProvider.historiLists.length <= 0
                  ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: AppConfig.appSize(context, .1),
                        ),
                        Text(
                          'Belum ada kunjungan',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: AppConfig.appSize(context, .013), fontWeight: FontWeight.bold, color: AppColors.darkGrey),
                        ),
                      ],
                    ),
                  )
                  : Column(
                    children: 
                    getChildrenWithSeperator(
                      addToLastChild: false,
                      widgets: ruteProvider.historiLists
                      .where((e) => e.status == _selectedFilter || _selectedFilter == '')
                      .map((e) {
                        return  Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          width: double.maxFinite,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                    ViewKunjungan(
                                      item: e,
                                    ),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    var begin = Offset(1.0, 0.0);
                                    var end = Offset.zero;
                                    var curve = Curves.easeInOut;
                                    var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    var slideAnimation = animation.drive(tween);

                                    return SlideTransition(
                                      position: slideAnimation,
                                      child: child,
                                    );
                                  },
                                ),
                              ).then((_) async {
                                widget.onPopulate();
                                final prefs = await SharedPreferences.getInstance(); 
                                prefs.setInt('kodesalesorder', 0);
                              });
                            },
                            child: visitCard(e),
                          ),
                        );
                      }).toList(),
                      seperator: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                        ),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                    ),
                  )
                ),
                SizedBox(height: AppConfig.appSize(context, .02),),
              ],
            ),
          );
        // );
      }
    );
  }

  Widget padded(Widget widget) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)),
      child: widget,
    );
  }    

Widget _buildFilterChip(String label, Color _color) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedFilter == label) {
             _selectedFilter = '';
          } else {
            _selectedFilter = label;
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal:  AppConfig.appSize(context, .012), vertical: AppConfig.appSize(context, .005)),
        decoration: BoxDecoration(
          color: isSelected ? _color : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _color,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : _color,
            fontWeight: FontWeight.bold,
            fontSize: AppConfig.appSize(context, .011),
          ),
        ),
      ),
    );
  }  

  Widget visitCard(RuteItem e) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "#${e.kode_sales_order}",
                      //   style: const TextStyle(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.bold,
                      //     color: AppColors.darkGrey
                      //   ),
                      // ),
                      Row(
                        children: [
                          Text(
                            "#${e.kode_sales_order}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey
                            ),
                          ),
                          SizedBox(width: AppConfig.appSize(context, .006),),
                          e.status == ''
                          ? Text('')
                          : Container(
                            padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .008), vertical: AppConfig.appSize(context, .002)),
                            decoration: BoxDecoration(
                              color: e.status == 'DRAFT' ? AppColors.lightAccentColor : e.status == 'POSTED' ? Colors.amber : AppColors.lightSecondaryColor,
                              borderRadius: BorderRadius.circular(AppConfig.appSize(context, .02))
                            ),
                            child: Text(
                              e.status,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),                      
                          )  
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        e.nama_customer,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
            
                    ],
                  ),
                ),
                Container(
                  width: AppConfig.appSize(context, .1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('d MMM y', 'id').format(DateFormat('yyyy-MM-dd').parse(e.tgl)),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),                             
                      Text(
                        e.jam_masuk,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        e.jam_keluar,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [         
                  Text(
                    'Total SKU: ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),                
                  Text(
                    '${e.totalSKU.round()}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),                
                  Spacer(),
                  Text(
                    'Total Value: ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),                
                  Text(
                    '${AppConfig.formatNumber(e.totalValue)}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),                
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _SortingSheetContent extends StatefulWidget {
  final ScrollController controller;
  final String? selectedStatus;   // <-- tambah parameter

  _SortingSheetContent({
    required this.controller,
    this.selectedStatus,          // <-- terima di constructor
  });

  @override
  __SortingSheetContentState createState() => __SortingSheetContentState();
}

class __SortingSheetContentState extends State<_SortingSheetContent> {
  String? selectedStatus;

  @override
  void initState() {
    super.initState();

    // isi dari parameter widget
    selectedStatus = widget.selectedStatus ?? 'Customer A-Z';
  }
  bool isAscending = true; // Default ke ascending
  List<String> listStatus = [
    'Customer A-Z',
    'Customer Z-A',
    'Tanggal Terkecil',
    'Tanggal Terbesar',
    'Nomor Nota Terkecil',
    'Nomor Nota Terbesar',
    'Total SKU Terkecil',
    'Total SKU Terbesar',
    'Total Value Terkecil',
    'Total Value Terbesar',
  ];

  void toggleSortDirection(String status) {
    setState(() {
      if (selectedStatus == status) {
        // Jika status yang sama diklik, ubah arah sorting
        isAscending = !isAscending;
      } else {
        // Jika memilih status baru, reset ke ascending
        selectedStatus = status;
        isAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Stack(
        children: [
          SingleChildScrollView(
            controller: widget.controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Sorting',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Daftar Status dengan Radio Buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: listStatus.map((status) {
                    return InkWell(
                      onTap: () => toggleSortDirection(status),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: status,
                            groupValue: selectedStatus,
                            onChanged: (value) {
                              // Tetap gunakan toggle untuk memastikan perubahan logika
                              toggleSortDirection(value!);
                            },
                            activeColor: AppColors.accentColor,
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  status,
                                  style: TextStyle(fontSize: 14),
                                ),
                                // if (selectedStatus == status)
                                //   Padding(
                                //     padding: const EdgeInsets.only(left: 8.0),
                                //     child: 
                                //     Icon(
                                //        isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                                //        size: 18,
                                //     )
                                //   ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 100),
              ],
            ),
          ),
          // Tombol Sticky di Bawah
          selectedStatus != null
              ? Positioned(
                  bottom: 30,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final jobprovider =
                          Provider.of<RuteProvider>(context, listen: false);
                      jobprovider.changeSortHistory(
                          selectedStatus ?? 'Customer A-Z');
                      jobprovider.sortByStatusHistory();

                      Navigator.pop(context, selectedStatus);
                    },
                    child: const Text('Terapkan Sorting', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }
}