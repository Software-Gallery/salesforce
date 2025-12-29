import 'dart:async';

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
import 'package:salesforce/models/rute_item.dart';
import 'package:salesforce/models/trn_sales_order_header.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/screens/tambah_kunjungan.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PilihCustomerScreen extends StatefulWidget {
  const PilihCustomerScreen({super.key});

  @override
  State<PilihCustomerScreen> createState() => _PilihCustomerScreenState();
}

class _PilihCustomerScreenState extends State<PilihCustomerScreen> {
  bool isTrnLoad = true;
  int currentPage = 1;
  ScrollController _scrollController = ScrollController();
  bool isLoadMore = false;
  late FocusNode _focusNodeSearch;
  TextEditingController _searchApproveController = TextEditingController(); 
  Timer? _debounce;   
  int iduser = -1;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _focusNodeSearch = FocusNode();
    _focusNodeSearch.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final SharedPreferences prefs = await SharedPreferences.getInstance();        
        setState(() {
          iduser = prefs.getInt('loginidkaryawan') ?? 0;              
        });
        final ruteProvider = Provider.of<RuteProvider>(context, listen: false);
        await ruteProvider.populateFromAdditional(iduser, currentPage, '').then((value) async {
          print(ruteProvider.additionalLists);
          await Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
              isTrnLoad = false;
            });
          });
        });     
        _scrollController.addListener(() async {
          if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) {
            setState(() {
              isLoadMore = true;
              currentPage += 1;
            });    
            await ruteProvider.loadMoreAdditional(iduser, currentPage, _searchApproveController.text);
            await Future.delayed(Duration(milliseconds: 500)).then((value) {
              setState(() {
                isLoadMore = false;
              });
            });
          }
        });
      } catch (e) {
        print(e.toString());
      }
    });
  }

  Future<void> openMap(String latlong) async {
    final url = Uri.parse('https://www.google.com/maps?q=${latlong}');

    if (await canLaunchUrl(url)) {
      await launchUrl(
        url,
        mode: LaunchMode.externalApplication, // 🔥 agar buka di aplikasi Maps
      );
    } else {
      throw 'Tidak bisa membuka URL: $url';
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }  

  @override
  Widget build(BuildContext context) {
    return Consumer<RuteProvider>(
      builder: (context, ruteProvider, child) {

        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white), 
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            title: Container(
              child: AppText(
                text: 'Extra Call',
                fontWeight: FontWeight.bold,
                fontSize: AppConfig.appSize(context, .016),
                color: Colors.white,
              ),
            ),
          ),          
          body: Column(
            children: [
              SizedBox(height: AppConfig.appSize(context, .01),),
              padded(
                Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        onEditingComplete: () {
                          setState(() {
                            _searchApproveController.text =
                                _searchApproveController.text.toUpperCase();
                          });
                        },
                        onTapOutside: (event) {
                          setState(() {
                            _searchApproveController.text =
                                _searchApproveController.text.toUpperCase();
                          });
                          _focusNodeSearch.unfocus();
                        },
                        controller: _searchApproveController,
                        focusNode: _focusNodeSearch,
                        onChanged: (text) {
                          if (_debounce?.isActive ?? false) _debounce?.cancel();
                          _debounce = Timer(Duration(seconds: 1), () async {
                            setState(() {
                              isTrnLoad = true;
                              currentPage = 1;
                            });
                            ruteProvider.populateFromAdditional(iduser, currentPage, _searchApproveController.text);
                            setState(() {
                              isTrnLoad = false;
                            });
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                            "assets/icons/search_icon.svg",
                            color: AppColors.secondaryColor,
                            fit: BoxFit.scaleDown,
                          ),
                          filled: !_focusNodeSearch.hasFocus,
                          fillColor: Colors.white,
                          // label: Text('Jam Server'),
                          hintText: 'Search...',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConfig.appSize(context, .014)),
                              borderSide:  BorderSide(
                                      color: Colors.black,
                                      width: 1.0,
                                    )),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(AppConfig.appSize(context, .014)),
                              borderSide: BorderSide(
                                      color: AppColors.darkGrey.withAlpha(50),
                                      width: 1.0,
                                    )),
                        ),
                      ),
                    ),
                    SizedBox(width: AppConfig.appSize(context, .01),),
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
                              initialChildSize: 0.6,
                              expand: false,
                              builder: (_, controller) => _SortingSheetContent(
                                selectedStatus: ruteProvider.currentSortAdditional,
                                controller: controller,), 
                            );
                          },
                        );  
                      },                              
                      child: Container(
                        width: AppConfig.appSize(context, .05),
                        height: AppConfig.appSize(context, .05),
                        padding: EdgeInsets.all(AppConfig.appSize(context, .016)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppConfig.appSize(context, .014)),
                          color: Colors.white,
                          border: Border.all(color: AppColors.darkGrey.withAlpha(50), width: 1)
                          // boxShadow: [
                          //   BoxShadow(color:  AppColors.darkGrey.withAlpha(50),blurRadius: 20, offset: Offset(0, 5))
                          // ]
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/filter.svg',
                          color: Colors.black,
                          // height: MediaQuery.sizeOf(context).height * .02,
                          // height: 20,
                        ),
                      ),
                    )                    
                  ],
                ),
              ),
              SizedBox(height: AppConfig.appSize(context, .01),),
              isTrnLoad
              ? Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: AppConfig.appSize(context, .02),
                    height: AppConfig.appSize(context, .02),
                    child: CircularProgressIndicator(
                      color: AppColors.darkSecondaryColor,
                    ),
                  ),
                )
              : Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: ruteProvider.additionalLists.length,
                  itemBuilder: (context, index) {
                    final e = ruteProvider.additionalLists[index];
                    
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: double.maxFinite,
                      child: GestureDetector(
                        onTap: () {
                          ruteProvider.setCurrent(e);
          
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                TambahKunjungan(
                                  jam: DateFormat('HH:mm:ss').format(DateTime.now()),
                                  isMasuk: true,
                                ),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                var begin = const Offset(1.0, 0.0);
                                var end = Offset.zero;
                                var curve = Curves.easeInOut;
          
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
          
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        child: visitCard(e, () {}),
                      ),
                    );
                  },
                ),
              ),
              // BOTTOM LOADING (load more)
              if (isLoadMore)
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: AppConfig.appSize(context, .03),
                    height: AppConfig.appSize(context, .03),
                    child: CircularProgressIndicator(
                      color: AppColors.darkSecondaryColor,
                    ),
                  ),
                ),
            ],
          ),
        );
      }
    );
  }

  Widget visitCard(RuteItem e, VoidCallback onVisit) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
    shadowColor: AppColors.darkGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.id_customer.toString(),
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    e.nama_customer,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    e.alamat_customer,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ), 
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'order created = ',
                          style: TextStyle(fontSize: 11, color: AppColors.accentColor)
                        ),
                        TextSpan(
                          text: e.jumlah_nota.toString(),
                          style: TextStyle(fontSize: 12, color: AppColors.accentColor)
                        ),
                        TextSpan(
                          text: ', overdue = ',
                          style: TextStyle(fontSize: 11, color: AppColors.accentColor)
                        ),                               
                        TextSpan(
                          text: AppConfig.formatNumber(e.sisa_piutang.toDouble()),
                          style: TextStyle(fontSize: 12, color: AppColors.accentColor)
                        ),                 
                      ]
                    ),
                  ),                         
                  // Row(
                  //   children: [
                                     
                      // Untuk Nota
                      // Row(
                      //   children: [
                      //     Text(
                      //       "Nota : ",
                      //       style: const TextStyle(
                      //         color: AppColors.accentColor,
                      //         fontSize: 11, // Font kecil untuk label
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     Text(
                      //       e.jumlah_nota.toString(),
                      //       style: const TextStyle(
                      //         color: AppColors.accentColor,
                      //         fontSize: 12, // Font normal untuk nilai
                      //         fontWeight: FontWeight.bold,
                      //         letterSpacing: .8
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // Text(', '),
                      // Row(
                      //   children: [
                      //     Text(
                      //       "Piutang : ",
                      //       style: const TextStyle(
                      //         color: AppColors.accentColor,
                      //         fontSize: 11, // Font kecil untuk label
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     Text(
                      //       AppConfig.formatNumber(e.sisa_piutang * 1.0),
                      //       style: const TextStyle(
                      //         color: AppColors.accentColor,
                      //         fontSize: 12, // Font normal untuk nilai
                      //         fontWeight: FontWeight.bold,
                      //         letterSpacing: .8
                      //       ),
                      //     ),
                      //   ],
                      // ),
                  //   ],
                  // ),                                
                  GestureDetector(
                    onTap: () {
                      openMap(e.latlong_customer);
                    },
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            "Lihat Lokasi",
                            style: TextStyle(
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13
                            ),
                          ),
                        ),              
                      ],
                    )
                  ),                  
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(AppConfig.appSize(context, .01)),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(AppConfig.appSize(context, .01))
              ),
              // height: AppConfig.appSize(context, .04),
              // width: AppConfig.appSize(context, .04),
              child: GestureDetector(
                onTap: onVisit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "VISIT",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 12
                      ),
                    ),
                    SizedBox(width: 5,),
                    SvgPicture.asset(
                      'assets/icons/arrow-right.svg',
                      // height: AppConfig.appSize(context, .018),
                      color: Colors.white,
                      height: 16,
                    ),                    
                  ],
                )
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget padded(Widget widget) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)),
      child: widget,
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
    'Order Created Terkecil',
    'Order Created Terbesar',
    'Overdue Terkecil',
    'Overdue Terbesar',
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
                      jobprovider.changeSortAdditional(
                          selectedStatus ?? 'Customer A-Z');
                      jobprovider.sortByStatus(true);

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