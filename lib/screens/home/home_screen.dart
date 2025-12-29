import 'dart:async';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/helpers/column_with_seprator.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/models/rute_item.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/provider/TrnSalesOrderHeaderProvider.dart';
import 'package:salesforce/screens/account/auth_page.dart';
import 'package:salesforce/screens/pilih_customer_screen.dart';
import 'package:salesforce/screens/tambah_kunjungan.dart';
import 'package:salesforce/services/auth_services.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slide_digital_clock_fork/slide_digital_clock_fork.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:url_launcher/url_launcher.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum totalState {
  today,
  weekly,
  monthly
}

class _HomeScreenState extends State<HomeScreen> {

  String cabang = '';

  Widget bestDealSlider = Container();
  bool bestDealSlideLoad = false;
  Widget newItemSlider = Container();
  bool newItemSlideLoad = true;
  bool usernameLoad = true;
  String tglaktif = '2025-12-31';

  late FocusNode _focusNodeSearch;

  TextEditingController _searchApproveController = TextEditingController();  
  bool isRuteLoad = true;

  @override
  void initState() {
    super.initState();
    _focusNodeSearch = FocusNode();
    _focusNodeSearch.addListener(() {
      setState(() {});
    });
    loadCabang();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await AuthService().checkVersion(
          () async {
            showForceUpdateDialog(
              context,
              message: "Versi aplikasi kamu sudah lama. Silakan update untuk melanjutkan.",
              updateUrl: "https://play.google.com/store/apps/details?id=com.softwaregallery.salesforce",
            );
          }
        );
        final ruteProvider = Provider.of<RuteProvider>(context, listen: false);
        await ruteProvider.populateTotal(totalCurrent.name);
        await ruteProvider.populateFromApi().then((value) async {
          await Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
              isRuteLoad = false; 
            });
          });
        });    
      } catch (e) {
        print(e.toString());
      }
    }); 
  }

  void showForceUpdateDialog(BuildContext context, {required String message, required String updateUrl}) {
    showDialog(
      context: context,
      barrierDismissible: false,   // Tidak bisa tap di luar
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,    // Blok tombol back
          child: AlertDialog(
            title: const Text(
              "Update Diperlukan",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(message),
            actions: [
              ElevatedButton(
                onPressed: () async {
                  // buka play store / web download
                  final uri = Uri.parse(updateUrl);
                  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                    throw 'Tidak dapat membuka URL: $uri';
                  }
                },
                child: const Text("Update"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor, // Warna background penuh
                    foregroundColor: Colors.white, // Warna teks putih
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20), // Tinggi tombol
                  ),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> loadCabang() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsusername = await prefs.getString('loginname') ?? '';
    final prefstglaktif = await prefs.getString('tglaktif') ?? '';
    setState(() {
      username = prefsusername;
      usernameLoad = false;
      tglaktif = prefstglaktif;
    });
  }
  String email = '';
  String username = '';  
  Future<void> setUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('email') ?? '';
      username = prefs.getString('username') ?? '';
    });
  }
  totalState totalCurrent = totalState.today;

  Timer? _debounce;

  @override
  void dispose() {
    // Membatalkan timer saat widget dihancurkan
    _debounce?.cancel();
    super.dispose();
  }  

  @override
  Widget build(BuildContext context) {

    return Consumer<RuteProvider>(
      builder: (context, ruteProvider, child) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: AppConfig.appSize(context, .2),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 255, 96, 28),
                      Color.fromARGB(255, 255, 121, 31),
                      Color.fromARGB(255, 238, 133, 63),
                      Color.fromARGB(255, 246, 153, 91),
                      Color.fromARGB(255, 243, 185, 146),
                      Color.fromARGB(255, 255, 238, 226),
                      Colors.white,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: AppConfig.appSize(context, .2),
              child: SvgPicture.asset(
                'assets/images/pattern_1.svg',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                colorBlendMode: BlendMode.overlay,
              ),
            ),

            Container(
              child: SingleChildScrollView(
                // physics: FixedExtentScrollPhysics(),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Localizations.override(
                        context: context,
                        locale: const Locale('en'),
                        child: Builder(
                          builder: (context) {
                            return heroWidget(ruteProvider);
                          },
                        ),
                      ),
                      // ElevatedButton(
                      //   onPressed: () async {
                      //     String imei = await FlutterDeviceImei.instance.getIMEI() ?? 'gagal ambil imei';
                      //     Utils.showActionSnackBar(context: context, text: "Device IMEI/Identifier: $imei", showLoad: false);                      
                      //   }, 
                      //   child: Text('Test')
                      // ),                                  
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
                                          
                                  // Setel timer baru untuk debounce
                                  _debounce = Timer(Duration(seconds: 1), () {
                                    ruteProvider.populateSearch(text);
                                  });
                                },
                                decoration: InputDecoration(
                                  prefixIcon: SvgPicture.asset(
                                    "assets/icons/search_icon.svg",
                                    color: AppColors.secondaryColor,
                                    fit: BoxFit.scaleDown,
                                  ),
                                  // filled: !_focusNodeSearch.hasFocus,
                                  filled: true,
                                  fillColor: Colors.white,
                                  // label: Text('Jam Server'),
                                  hintText: 'Search...',
                                  hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w400),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(AppConfig.appSize(context, .018))),
                                      borderSide: 
                                          BorderSide.none),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(AppConfig.appSize(context, .018))),
                                      borderSide: _focusNodeSearch.hasFocus
                                          ? BorderSide(
                                              color: Colors.black,
                                              width: 2.0,
                                            )
                                          : BorderSide.none),
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
                                        selectedStatus: ruteProvider.currentSort,
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
                                  borderRadius: BorderRadius.circular(AppConfig.appSize(context, .018)),
                                  color: Colors.white
                                ),
                                child: SvgPicture.asset(
                                  'assets/icons/filter.svg',
                                  color: Colors.black,
                                  // height: MediaQuery.sizeOf(context).height * .02,
                                  // height: 20,
                                ),
                              ),
                            )
                            // ElevatedButton(
                            //   onPressed: () {
                            //     showModalBottomSheet<void>(
                            //       backgroundColor: Colors.white,
                            //       showDragHandle: true,
                            //       useSafeArea: true,
                            //       isScrollControlled: true,
                            //       context: context,
                            //       builder: (BuildContext context) {
                            //         return DraggableScrollableSheet(
                            //           snapSizes: [0.5,0.9],
                            //           initialChildSize: 0.5,
                            //           expand: false,
                            //           builder: (_, controller) => _SortingSheetContent(
                            //             controller: controller,), 
                            //         );
                            //       },
                            //     );  
                            //   },
                            //   style: ElevatedButton.styleFrom(
                            //     padding: const EdgeInsets.all(10),
                            //     shape: RoundedRectangleBorder(
                            //       borderRadius: BorderRadius.circular(100),
                            //     ),
                            //   ),
                            //   child: SvgPicture.asset(
                            //     'assets/icons/filter.svg',
                            //     color: Colors.black,
                            //     // height: MediaQuery.sizeOf(context).height * .02,
                            //     height: 20,
                            //   ),
                            // ),                             
                          ],
                        ),
                      ),
                      SkeletonLoader(
                        isLoading: isRuteLoad,
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
                                    horizontal: 20,
                                  ),
                                  width: double.maxFinite,
                                  child: 
                                  Skeleton.leaf(
                                    child: visitCard(e, () {})
                                  )
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
                        ruteProvider.tempItemLists.length <= 0
                        ? Center(
                          child: Column(
                            children: [
                              SizedBox(
                                height: AppConfig.appSize(context, .02),
                              ),
                              extraButton()
                            ],
                          ),
                        )
                        : Column(
                          children: 
                          getChildrenWithSeperator(
                            addToLastChild: true,
                            widgets: [
                              // daftar item yang sudah ada
                              ...ruteProvider.tempItemLists.map((e) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  width: double.maxFinite,
                                  child: GestureDetector(
                                    onTap: () async {
                                      ruteProvider.setCurrent(e);
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => 
                                            TambahKunjungan(
                                              jam: DateFormat('HH:mm:ss').format(DateTime.now()), 
                                              isMasuk: true,
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
                                      );
                                    }, 
                                    child: visitCard(e, () async {
                                      ruteProvider.setCurrent(e);
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) => 
                                            TambahKunjungan(
                                              jam: DateFormat('HH:mm:ss').format(DateTime.now()), 
                                              isMasuk: true,
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
                                      );
                                    }),
                                  ),
                                );
                              }),    
                              extraButton()                
                            ],
                            seperator: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 25),
                              child: Divider(thickness: 1),
                            ),
                          )
            
                        )
                      ),          
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }); 
  }
  

  Widget visitCard(RuteItem item, VoidCallback onVisit) {
    List<String> days = [];
    if (item.day1 == 1) days.add('sen');
    if (item.day2 == 1) days.add('sel');
    if (item.day3 == 1) days.add('rab');
    if (item.day4 == 1) days.add('kam');
    if (item.day5 == 1) days.add('jum');
    if (item.day6 == 1) days.add('sab');
    if (item.day7 == 1) days.add('min');
    String daysString = days.join(', ');
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      shadowColor: AppColors.darkGrey.withAlpha(50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Row(
          children: [
            // Kiri: Nama dan tanggal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.nama_customer}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   'testtt',
                  //   // "${DateFormat('yyyy-MM-dd').format(item.tgl_aktif)}",
                  //   style: const TextStyle(
                  //     fontSize: 14,
                  //     // fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  Text(
                    item.alamat_customer,
                    style: const TextStyle(
                      color: AppColors.darkGrey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10,),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'order created = ',
                          style: TextStyle(fontSize: 11, color: AppColors.accentColor)
                        ),
                        TextSpan(
                          text: item.jumlah_nota.toString(),
                          style: TextStyle(fontSize: 12, color: AppColors.accentColor)
                        ),
                        TextSpan(
                          text: ', overdue = ',
                          style: TextStyle(fontSize: 11, color: AppColors.accentColor)
                        ),                               
                        TextSpan(
                          text: AppConfig.formatNumber(item.sisa_piutang.toDouble()),
                          style: TextStyle(fontSize: 12, color: AppColors.accentColor)
                        ),                 
                      ]
                    ),
                  ),
                  // Text(
                  //   "order created = 2, overdue = 2 invoices (2.500.000)",
                  //   style: const TextStyle(
                  //     color: AppColors.accentColor,
                  //     fontSize: 11, // Font kecil untuk label
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // Row(
                  //   children: [
                  //     // Untuk Nota
                  //     Row(
                  //       children: [
                  //         Text(
                  //           "order created = ",
                  //           style: const TextStyle(
                  //             color: AppColors.accentColor,
                  //             fontSize: 11, // Font kecil untuk label
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //         Text(
                  //           item.jumlah_nota.toString(),
                  //           style: const TextStyle(
                  //             color: AppColors.accentColor,
                  //             fontSize: 12, // Font normal untuk nilai
                  //             fontWeight: FontWeight.bold,
                  //             letterSpacing: .8
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //     Text(', '),
                  //     Row(
                  //       children: [
                  //         Text(
                  //           "overdue = ",
                  //           style: const TextStyle(
                  //             color: AppColors.accentColor,
                  //             fontSize: 11, // Font kecil untuk label
                  //             fontWeight: FontWeight.bold,
                  //           ),
                  //         ),
                  //         Text(
                  //           AppConfig.formatNumber(item.sisa_piutang * 1.0),
                  //           style: const TextStyle(
                  //             color: AppColors.accentColor,
                  //             fontSize: 12, // Font normal untuk nilai
                  //             fontWeight: FontWeight.bold,
                  //             letterSpacing: .8
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  // Text(
                  //   "Piutang : ${AppConfig.formatNumber(item.sisa_piutang * 1.0)}",
                  //   style: const TextStyle(
                  //     color: AppColors.darkGrey,
                  //     fontSize: 11,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 5),
              padding: EdgeInsets.all(AppConfig.appSize(context, .01)),
              decoration: BoxDecoration(
                color: item.jml_absen > 0 ? Colors.amber : AppColors.secondaryColor,
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

  Widget subTitle(String text, StatefulWidget halaman) {
    return Row(
      children: [
      Text(
          text,
          style: TextStyle(fontSize: AppConfig.appSize(context, .016), fontWeight: FontWeight.bold),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => halaman,
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // Mengatur animasi slide
                  var begin = Offset(1.0, 0.0); // Mulai dari sebelah kanan
                  var end = Offset.zero; // Tujuan ke posisi akhir (ke tengah)
                  var curve = Curves.easeInOut;

                  var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var slideAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: slideAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.only(
              left: AppConfig.appSize(context, .025), 
            ),
            // color: Colors.amber,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Text(
                //   "${AppLocalizations.of(context)!.home_produk_slder_more}",
                //   style: TextStyle(
                //       fontSize: AppConfig.appSize(context, .012),
                //       fontWeight: FontWeight.bold,
                //       color: AppColors.secondaryColor),
                // ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  GlobalKey menuKey = GlobalKey();
  Widget heroWidget(RuteProvider ruteProvider) {
    bool isTotalLoad = false;
    return Container(
      height: AppConfig.appSize(context, .12),
      // padding: EdgeInsets.only(top: 40),
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [
      //       Color.fromARGB(255, 255, 96, 28),
      //       const Color.fromARGB(255, 255, 121, 31),
      //       const Color.fromARGB(255, 238, 133, 63),
      //       const Color.fromARGB(255, 246, 153, 91),
      //       const Color.fromARGB(255, 243, 185, 146),
      //       const Color.fromARGB(255, 255, 238, 226),
      //       Colors.white,
      //   ])
      // ),
      child: Stack(
        children: [
          // Positioned.fill(
          //   child: SvgPicture.asset(
          //     'assets/images/pattern_1.svg',
          //     fit: BoxFit.cover,
          //     alignment: Alignment.topCenter,
          //     colorBlendMode: BlendMode.overlay, 
          //     // color: Colors.white.withOpacity(0.1), // Optional tint
          //   ),
          // ),             
          Column(
            children: [
              SizedBox(height: AppConfig.appSize(context, .06),),
              padded(
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SkeletonLoader(isLoading: usernameLoad, 
                            skeleton: Skeletonizer(
                              effect: ShimmerEffect(
                                baseColor: const Color.fromARGB(41, 238, 238, 238),
                                highlightColor: const Color.fromARGB(164, 255, 255, 255),
                                duration: Duration(milliseconds: 1200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    "Helo, Lorem ipsum",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontSize: AppConfig.appSize(context, .02),
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '2025-01-01',
                                    // DateFormat('EEE, d MMM y', 'id').format(DateTime.now()),
                                    style: TextStyle(
                                      fontSize: AppConfig.appSize(context, .015),
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),                                  
                                ],
                              )
                            ), 
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,                              
                              children: [                                
                                Text(
                                  "${AppLocalizations.of(context)!.home_welcome_word}, $username",
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: AppConfig.appSize(context, .02),
                                    fontFamily: 'Gilroy',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEE, d MMM y', 'id').format(DateFormat('yyyy-MM-dd').parse(tglaktif)),
                                  // DateFormat('EEE, d MMM y', 'id').format(DateTime.now()),
                                  style: TextStyle(
                                    fontSize: AppConfig.appSize(context, .015),
                                    fontFamily: 'Gilroy',
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),                                
                              ],
                            ),
                          ),
                          // Text(
                          //   DateFormat('EEE, d MMM y', 'id').format(DateFormat('yyyy-MM-dd').parse(tglaktif)),
                          //   // DateFormat('EEE, d MMM y', 'id').format(DateTime.now()),
                          //   style: TextStyle(
                          //     fontSize: AppConfig.appSize(context, .015),
                          //     fontFamily: 'Gilroy',
                          //     fontWeight: FontWeight.w700,
                          //     color: Colors.white,
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                      final RenderBox overlay =
                      Overlay.of(context).context.findRenderObject() as RenderBox;
                      final RenderBox button =
                      menuKey.currentContext!.findRenderObject() as RenderBox;
                      final Offset position =
                      button.localToGlobal(Offset.zero, ancestor: overlay);
                      showMenu<String>(
                          context: context,
                          position: RelativeRect.fromLTRB(position.dx, position.dy, 0, 0),
                          items: <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'logout',
                              child: Row(
                                children: [
                                  Text('Logout'),
                                  const SizedBox(width: 10), // Spasi antara ikon dan teks
                                  Icon(Icons.logout), // Tambahkan ikon di sini
                                ],
                              ),
                            ),
                            // Tambahkan pilihan lain jika diperlukan
                          ],
                        ).then((String? choice) async {
                          if (choice == 'logout') {
                            final prefs = await SharedPreferences.getInstance();
                            prefs.setInt('loginid', -1);
                            Navigator.of(context).pushReplacement(new MaterialPageRoute(
                              builder: (BuildContext context) {
                                return AuthPage();
                              },
                            ));                                  
                          } else if (choice == 'setting') {
                            
                          }
                        });                        
                      },
                      child: ClipOval(
                        key: menuKey,
                        child: Image.asset(
                          'assets/images/user.png', // CATATAN: .svg tidak didukung oleh Image.asset!
                          width: AppConfig.appSize(context, .05),
                          height: AppConfig.appSize(context, .05),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: AppConfig.appSize(context, .05),
                            height: AppConfig.appSize(context, .05),
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.person,
                              size: AppConfig.appSize(context, .05) * 0.6,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    )  
                  ],
                ),
                ),

                // padded(
                //   Row(
                //     children: [
                //       DigitalClock(
                //         hourMinuteDigitTextStyle: TextStyle(
                //           color: Colors.white,
                //           fontSize: 30,
                //           fontWeight: FontWeight.bold,
                //         ),
                //         secondDigitTextStyle: TextStyle(
                //           color: Colors.white,
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //         colon: Text(
                //           ":",
                //           style: Theme.of(context).textTheme.titleLarge!.copyWith(
                //                 color: Colors.white,
                //               ),
                //         ),
                //       ),
                //     ],
                //   )
                // ),
              SizedBox(height: AppConfig.appSize(context, .01),),
              // padded(
              //   Container(
              //     padding: EdgeInsets.all(AppConfig.appSize(context, .012)),
              //     width: double.maxFinite,
              //     decoration: BoxDecoration(
              //       color: Colors.white,
              //       borderRadius: BorderRadius.circular(AppConfig.appSize(context, .015)),
              //       boxShadow: [
              //         BoxShadow(color: AppColors.darkGrey.withOpacity(.1),offset: Offset(0, 4), blurRadius: 5)
              //       ]
              //     ),
              //     child: Column(
              //       children: [
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.start, 
              //           children: [
              //             Text(
              //               "Total Visit",
              //               style: TextStyle(
              //                   fontSize: AppConfig.appSize(context, .018),
              //                   fontWeight: FontWeight.w900,),
              //             ),
              //             Spacer(),
              //             // Text(
              //             //   "${AppLocalizations.of(context)!.home_produk_slder_more}",
              //             //   style: TextStyle(
              //             //       fontSize: AppConfig.appSize(context, .012),
              //             //       fontWeight: FontWeight.bold,
              //             //       color: AppColors.secondaryColor),
              //             // ),                      
              //           ],
              //         ),
              //         SkeletonLoader(
              //           isLoading: isTotalLoad,
              //           skeleton: Skeletonizer(
              //             justifyMultiLineText: false,
              //             textBoneBorderRadius: TextBoneBorderRadius.fromHeightFactor(.3),
              //             effect: ShimmerEffect(
              //               baseColor: Colors.grey.shade200,
              //               highlightColor: Colors.white,
              //               duration: Duration(milliseconds: 1200),
              //             ),
              //             child: Text(
              //               '0000',
              //               textAlign: TextAlign.center,
              //               style: TextStyle(
              //                   color: AppColors.primaryColor,
              //                   fontSize: AppConfig.appSize(context, .04),
              //                   fontWeight: FontWeight.w900,),
              //             ),
              //           ), 
              //           child: Center(
              //             child: Text(
              //               ruteProvider.total.toString(),
              //               textAlign: TextAlign.center,
              //               style: TextStyle(
              //                   color: AppColors.primaryColor,
              //                   fontSize: AppConfig.appSize(context, .04),
              //                   fontWeight: FontWeight.w900,),
              //             ),
              //           ),
              //         ),     
              //         Row(
              //           mainAxisAlignment: MainAxisAlignment.start, 
              //           children: [
              //             SvgPicture.asset(
              //               "assets/icons/swap.svg",
              //               width: AppConfig.appSize(context, .018),
              //               height: AppConfig.appSize(context, .018),
              //               color: AppColors.accentColor,
              //             ),
              //             SizedBox(width: AppConfig.appSize(context, .01),),
              //             GestureDetector(
              //             child: Text(
              //               totalCurrent == totalState.today ? 'Today' : totalCurrent == totalState.weekly ? 'Weekly' : totalCurrent == totalState.monthly ? 'Monthly' : '',
              //               style: TextStyle(
              //                 fontSize: AppConfig.appSize(context, .012),
              //                 fontWeight: FontWeight.w900,
              //                 color: AppColors.accentColor
              //               ),
              //             ),
              //             onTap: () async {
              //               setState(() {
              //                 isTotalLoad = true;
              //               });
              //               if (totalCurrent == totalState.today) {
              //                 setState(() {
              //                   totalCurrent = totalState.weekly;
              //                 });
              //               } else if (totalCurrent == totalState.weekly) {
              //                 setState(() {
              //                   totalCurrent = totalState.monthly;
              //                 });
              //               } else if (totalCurrent == totalState.monthly) {
              //                 setState(() {
              //                   totalCurrent = totalState.today;
              //                 });
              //               }
              //               await ruteProvider.populateTotal(totalCurrent.name);  
              //               setState(() {
              //                 isTotalLoad = false;
              //               });
              //             },
              //             )
              //           ],
              //         ),                                 
              //       ],
              //     )
              //   )
              // )
            ],
          ),       
        ],
      )
    );
  }

  Widget extraButton() {
    return GestureDetector(
      onTap: () async {
        // ruteProvider.setCurrent(e);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => PilihCustomerScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Mengatur animasi slide
              var begin = Offset(1.0, 0.0); // Mulai dari sebelah kanan
              var end = Offset.zero; // Tujuan ke posisi akhir (ke tengah)
              var curve = Curves.easeInOut;

              var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
              var slideAnimation = animation.drive(tween);

              return SlideTransition(
                position: slideAnimation,
                child: child,
              );
            },
          ),
        );
      }, 
      child:  Container(
        margin: EdgeInsets.symmetric(
          horizontal: AppConfig.appSize(context, .02),
        ),
        color: Colors.white,
        width: double.maxFinite,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            radius: Radius.circular(AppConfig.appSize(context, 0.01)),
            dashPattern: [5, 5],
            color: AppColors.accentColor,
            strokeWidth: 2,
          ),
          child: Center(
            child: Container(
              padding: EdgeInsets.all(AppConfig.appSize(context, .014),),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Tambah Extra Call",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppConfig.appSize(context, .012),
                      color: AppColors.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SvgPicture.asset(
                    'assets/icons/arrow-right.svg',
                    // height: AppConfig.appSize(context, .018),
                    color: AppColors.accentColor,
                    height: 16,
                  ),                                   
                ],
              ),
            ),
          )
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
                      jobprovider.changeSort(
                          selectedStatus ?? 'Customer A-Z');
                      jobprovider.sortByStatus(false);

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


