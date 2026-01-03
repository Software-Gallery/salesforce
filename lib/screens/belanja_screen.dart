import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/barang_promo_item_card_widget.dart';
import 'package:salesforce/common_widgets/currency_input_formatter.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/provider/setting_provider.dart';
import 'package:salesforce/screens/barang_details_screen.dart';
import 'package:salesforce/screens/cart_screen.dart';
import 'package:salesforce/screens/search_screen.dart';
import 'package:salesforce/services/BarangService.dart';
import 'package:salesforce/services/TrnSalesOrderServices.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BelanjaScreen extends StatefulWidget {
  const BelanjaScreen({super.key});

  @override
  State<BelanjaScreen> createState() => BelanjaScreenState();
}

class BelanjaScreenState extends State<BelanjaScreen> with SingleTickerProviderStateMixin {
  
  Widget barangGrid = Center(child: Text('Belum Ada Promo'),);
  bool bestDealSlideLoad = true;
  Widget categoriesHorizontalScroll = Container();
  late FocusNode _focusNodeSearch;

  TextEditingController _searchApproveController = TextEditingController();    

  late TabController _tabController;
  late ScrollController _scrollController;  

  List<GlobalKey> tabKeys = List.generate(7, (_) => GlobalKey());

  void _scrollToActiveTab(int index) {
    double offset = 0.0;

    // Sum up the widths of the tabs before the selected one
    for (int i = 0; i < index; i++) {
      final keyContext = tabKeys[i].currentContext;
      if (keyContext != null) {
        final box = keyContext.findRenderObject() as RenderBox;
        offset += (box.size.width + AppConfig.appSize(context, .02));
      }
    }

    // Ensure we don't scroll out of bounds by capping the offset
    final maxScrollExtent = _scrollController.position.maxScrollExtent;
    if (offset > maxScrollExtent) {
      offset = maxScrollExtent;
    }

    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _focusNodeSearch = FocusNode();
    _focusNodeSearch.addListener(() {
      setState(() {});
    });
    _tabController = TabController(length: 7, vsync: this);
    _scrollController = ScrollController();
  

    // Listener untuk mendeteksi perubahan tab
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _scrollToActiveTab(_tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final barangProvider = Provider.of<BarangProvider>(context, listen: false);
        final settingProvider = Provider.of<SettingProvider>(context, listen: false);
        barangProvider.belanjaPopulateFromApi().then((value) {
          setState(() {
            bestDealSlideLoad = false;
          });
        }); 
      } catch (e) {
        print(e.toString());
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

  return Consumer2<BarangProvider, SettingProvider>(
    builder: (context, barangProvider, settingProvider, child) {
    Widget _buildBarangList(BuildContext context, int category) {
      return SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .008)),
          child: Column(
            children: [
              SkeletonLoader(
                isLoading: bestDealSlideLoad,
                skeleton: Skeletonizer(
                  effect: ShimmerEffect(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    duration: Duration(milliseconds: 1200),
                  ),
                  child: StaggeredGrid.count(
                    crossAxisCount: 1,
                    children: barangList.map<Widget>((barangItem) {
                      return Skeleton.leaf(
                        child: Container(
                          // margin: EdgeInsets.only(left: AppConfig.appSize(context, .02), right: AppConfig.appSize(context, .02)),
                          // padding: EdgeInsets.only(top: AppConfig.appSize(context, .01), bottom: AppConfig.appSize(context, .01)),
                          height: AppConfig.appSize(context, .06),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppConfig.appSize(context, .01))
                            // border: Border(
                            //   bottom: BorderSide(
                            //     color: false
                            //         ? Colors.white
                            //         : AppColors.darkGrey.withOpacity(.2), // Warna border bawah
                            //     width: 1.0, // Ketebalan border
                            //   ),
                            // ),
                          ),
                        )
                      );
                    }).toList(),
                    mainAxisSpacing: AppConfig.appSize(context, .002),
                    crossAxisSpacing: AppConfig.appSize(context, .001),
                  ),
                ), 
                child: StaggeredGrid.count(
                  crossAxisCount: 1,
                  children: barangProvider.itemSearchLists.map<Widget>((barangItem) {
                    return 
                    settingProvider.isImageItem 
                    ? GestureDetector(
                      onTap: () {
                        onItemClicked(context, barangItem);  
                      },
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: BarangPromoItemCardWidget(
                          item: barangItem,
                          heroSuffix: "explore_screen",
                        ),
                      ),
                    )
                    : GestureDetector(
                      onTap: () {
                        // onItemClicked(context, barangItem);  
                        changeQtySheet(barangItem, barangProvider);
                      },
                      child: Container(
                        // margin: EdgeInsets.only(left: AppConfig.appSize(context, .02), right: AppConfig.appSize(context, .02)),
                        padding: EdgeInsets.only(top: AppConfig.appSize(context, .01), bottom: AppConfig.appSize(context, .01)),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: false
                                  ? Colors.white
                                  : AppColors.darkGrey.withOpacity(.2), // Warna border bawah
                              width: 1.0, // Ketebalan border
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded( // Use Expanded to prevent overflow
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
                                children: [
                                  Text(
                                    barangItem.nama_barang,
                                    style: TextStyle(
                                      fontSize: AppConfig.appSize(context, .014),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true, // Allow text to wrap
                                    maxLines: null, // Allow unlimited lines
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      AppText(
                                        text: "${barangItem.kode_barang}",
                                        color: AppColors.darkGrey,
                                        fontSize: AppConfig.appSize(context, .012),
                                        fontWeight: FontWeight.bold,
                                      ),  
                                      RichText(text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "QTY :",
                                            style: TextStyle(
                                              color: AppColors.primaryColor
                                            ),
                                          ),
                                          TextSpan(
                                            text: "${barangItem.qty_besar.toInt()}.${barangItem.qty_tengah.toInt()}.${barangItem.qty_kecil.toInt()}",
                                            style: TextStyle(
                                              color: AppColors.primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'arial'
                                            ),
                                          ),
                                        ]
                                      )),
                                      Text(
                                        "${CurrencyInputFormatter().currencyFormatter.format(barangItem.harga.toInt())}",
                                        style: TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: AppConfig.appSize(context, .012),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),     
                                      // SizedBox(width: 5,),
                                      // addWidget(context)                                      
                                    ],
                                  ),                            
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  mainAxisSpacing: AppConfig.appSize(context, .002),
                  crossAxisSpacing: AppConfig.appSize(context, .001),
                ), 
              ),
              SizedBox(height: AppConfig.appSize(context, .18),)
            ],
          )
        ),
      );
    }
    
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            top: AppConfig.appSize(context, .08), // Adjust this based on the size of the search bar and tab bar
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height, // Adjust the height if needed
                    padding: EdgeInsets.only(top: AppConfig.appSize(context, .03), left: AppConfig.appSize(context, .012), right: AppConfig.appSize(context, .012)),
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: List.generate(7, (index) => _buildBarangList(context, index + 1)),
                    ),
                  ),
                  Divider(color: AppColors.darkGrey.withOpacity(.3)),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: AppConfig.appSize(context, .01),
                top: AppConfig.appSize(context, .048),
                left: AppConfig.appSize(context, .02),
                right: AppConfig.appSize(context, .02),
              ),
              height: AppConfig.appSize(context, .1),
              color: AppColors.primaryColor,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.only( 
                        right: AppConfig.appSize(context, .01), 
                        bottom: AppConfig.appSize(context, .01),
                        top: AppConfig.appSize(context, .01)
                      ),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/arrow-left.svg',
                            height: AppConfig.appSize(context, .018),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                        onTapOutside: (event) {
                          _focusNodeSearch.unfocus();
                        },
                        controller: _searchApproveController,
                        focusNode: _focusNodeSearch,
                        onChanged: (text) {
                          // print(text);
                          barangProvider.populateSearch(text);
                        },
                        decoration: InputDecoration(
                          prefixIcon: SvgPicture.asset(
                            "assets/icons/search_icon.svg",
                            color: AppColors.secondaryColor,
                            fit: BoxFit.scaleDown,
                          ),
                          filled: true,
                          fillColor: AppColors.grey,
                          // label: Text('Jam Server'),
                          hintText: 'Ketik ID Barang/Nama',
                          hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide:BorderSide.none),
                        ),
                      ),
                  ),                            
                          
                  // searchWidget(),
                  // GestureDetector(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       PageRouteBuilder(
                  //         pageBuilder: (context, animation, secondaryAnimation) => CartScreen(),
                  //         transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  //           var begin = 0.0;
                  //           var end = 1.0;
                  //           var curve = Curves.easeInOut;

                  //           var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  //           var fadeAnimation = animation.drive(tween);

                  //           return FadeTransition(
                  //             opacity: fadeAnimation,
                  //             child: child,
                  //           );
                  //         },
                  //       ),
                  //     );
                  //   },
                  //   child: Container(
                  //     padding: EdgeInsets.only( 
                  //       left: AppConfig.appSize(context, .01), 
                  //       bottom: AppConfig.appSize(context, .01),
                  //       top: AppConfig.appSize(context, .01)
                  //     ),
                  //     color: Colors.transparent,
                  //     child: Row(
                  //       children: [
                  //         SvgPicture.asset(
                  //           'assets/icons/cart_icon.svg',
                  //           height: AppConfig.appSize(context, .018),
                  //           color: Colors.white,
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );});
  }

  Widget addWidget(BuildContext context) {
    return Container(
      height: AppConfig.appSize(context, .03),
      width: AppConfig.appSize(context, .03),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConfig.appSize(context, .012)),
          color: AppColors.secondaryColor),
      child: Center(
        child: Icon(
          Icons.add,
          color: Colors.white,
          size: AppConfig.appSize(context, .022),
        ),
      ),
    );
  }    

  void onItemClicked(BuildContext context, BarangItem barangItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BarangDetailsScreen(
          barangItem,
          false,
          heroSuffix: "explore_screen",
        ),
      ),
    );
  }

  Widget searchWidget() {
    final String searchIcon = "assets/icons/search_icon.svg";
    // final String scannerIcon = "assets/icons/scanner.svg";
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => SearchScreen(),));
        },
        child: Container(
          // padding: EdgeInsets.all(AppConfig.appSize(context, .012)),
          padding: EdgeInsets.only(
            left:  AppConfig.appSize(context, .012)
          ),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.appSize(context, .015)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(
                searchIcon,
                color: AppColors.secondaryColor,
                height: AppConfig.appSize(context, .016),
              ),
              SizedBox(
                width: AppConfig.appSize(context, .008),
              ),
              Text(
                "Cari produk",
                style: TextStyle(
                    fontSize: AppConfig.appSize(context, .013),
                    //fontWeight: FontWeight.bold,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGrey),
              ),
              Flexible(child: Container()),
              GestureDetector(
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   PageRouteBuilder(
                  //     pageBuilder: (context, animation, secondaryAnimation) => ScanCamera(),
                  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  // const begin = Offset(0.0, 1.0);
                  // const end = Offset(0.0, 0.0);
                  // const curve = Curves.ease;
                  
                  // var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  // var offsetAnimation = animation.drive(tween);
                  
                  // return SlideTransition(
                  //   position: offsetAnimation,
                  //   child: child,
                  // );
                  //     },
                  //   ),
                  // );
                },                  
                child: Container(
                  height: AppConfig.appSize(context, .04),
                  padding: EdgeInsets.only(
                    right: AppConfig.appSize(context, .012),
                    left:  AppConfig.appSize(context, .01)
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    // borderRadius: BorderRadius.circular(AppConfig.appSize(context, .015)),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(AppConfig.appSize(context, .015)),
                      bottomRight: Radius.circular(AppConfig.appSize(context, .015)),
                    )
                  ),
                  child: Container()
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> changeQtySheet(BarangItem item, BarangProvider barangProvider) async {
    TextEditingController _budgetApproveController = TextEditingController();
    TextEditingController _discCashController = TextEditingController();
    TextEditingController _discPersenController = TextEditingController();
    TextEditingController _keteranganController = TextEditingController();
    String? _selectedValue = item.status == '' ? 'REGULAR' : item.status;
    bool isLoadSaveToCart = false;
    // BarangItem barang = barangProvider.itemCartLists.firstWhere(
    //   (brg) => brg.id_barang == item.id_barang && brg.status == item.status, 
    //   orElse: () => BarangItem(id_barang: -1, kode_barang: '1', id_departemen: 1, nama_barang: '', satuan_besar: 1, satuan_tengah: 1, satuan_kecil: 0, konversi_besar: 0, konversi_tengah: 0, gambar: '', is_aktif: 1, harga: 0, qty_besar: 0, qty_tengah: 0, qty_kecil: 0, disc_cash: 0, disc_perc: 0, ket_detail: '', subtotal: 0, total: 0, status: ''),
    // );
    // String recentQty = barangProvider.loadQty(item.id_barang!);
    // _budgetApproveController.text=recentQty;
    // _discCashController.text="${barang.disc_cash.round()}";
    // _discPersenController.text="${barang.disc_perc.round()}";
    // _keteranganController.text="${barang.ket_detail}";
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            // Adjust the bottom padding to account for the keyboard height
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: AppConfig.appSize(context, .52),
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(
              vertical: AppConfig.appSize(context, .02),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: Container(
                      width: double.maxFinite,
                      child: AppText(
                        color: AppColors.darkGrey,
                        text: item.kode_barang,
                        fontSize: AppConfig.appSize(context, .012),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: Container(
                      width: double.maxFinite,
                      child: AppText(
                        text: item.nama_barang,
                        fontSize: AppConfig.appSize(context, .018),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: AppConfig.appSize(context, .01)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: captionForm('Quantity'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      controller: _budgetApproveController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        // FilteringTextInputFormatter.digitsOnly,
                        // CurrencyInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: 'Examples: 1.1.1',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppConfig.appSize(context, .014)),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppConfig.appSize(context, .014)),
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppConfig.appSize(context, .01),),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: Row(
                      children: [
                        Flexible(
                          child: Column(
                            children: [
                              captionForm('Diskon Cash'),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  // horizontal: AppConfig.appSize(context, .024),
                                ),
                                child: TextFormField(
                                  enabled: _selectedValue == 'REGULAR',
                                  textInputAction: TextInputAction.done,
                                  controller: _discCashController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    // FilteringTextInputFormatter.digitsOnly,
                                    // CurrencyInputFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    hintText: 'Diskon Cash',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(AppConfig.appSize(context, .014)),
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(AppConfig.appSize(context, .014)),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(AppConfig.appSize(context, .014)),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),          
                        SizedBox(width: AppConfig.appSize(context, .01),),
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              // horizontal: AppConfig.appSize(context, .024),
                            ),
                            child: Column(
                              children: [
                                captionForm('Diskon Persen'),
                                TextFormField(
                                  enabled: _selectedValue == 'REGULAR',
                                  textInputAction: TextInputAction.done,
                                  controller: _discPersenController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    // FilteringTextInputFormatter.digitsOnly,
                                    // CurrencyInputFormatter(),
                                  ],
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.grey.shade200,
                                    hintText: 'Diskon Persen',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(AppConfig.appSize(context, .014)),
                                      ),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(AppConfig.appSize(context, .014)),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),                                    
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(AppConfig.appSize(context, .014)),
                                      ),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),              
                      ],
                    ),
                  ),
                  SizedBox(height: AppConfig.appSize(context, .01)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: captionForm('Keterangan')
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      controller: _keteranganController,
                      // keyboardType: TextInputType.number,
                      maxLines: 2,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: 'Keterangan',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppConfig.appSize(context, .014)),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppConfig.appSize(context, .014)),
                          ),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),                  
                  SizedBox(height: AppConfig.appSize(context, .01)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: captionForm('Status')
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedValue,
                      hint: Text('Status'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: 'Pilihan',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppConfig.appSize(context, .014)),
                          ),
                          borderSide: BorderSide(
                            color: Colors.black, // Warna border saat focus (sesuaikan)
                            width: 1.0,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppConfig.appSize(context, .014)),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(AppConfig.appSize(context, .014)),
                          ),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 16.0,
                        ),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.0,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey.shade600,
                      ),
                      iconSize: 24.0,
                      isExpanded: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedValue = newValue;
                        });
                      },
                      items: <String>['REGULAR', 'BONUS']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),       
                  SizedBox(height: AppConfig.appSize(context, .02)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: Container(
                      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: AppButtonColor(
                        border: null,
                        isEnabled: true,
                        onPressed: () async {
                          try {
                            setState(() {
                              isLoadSaveToCart = true;
                            });
                            if (_discCashController.text == '') _discCashController.text = '0';
                            if (_discPersenController.text == '') _discPersenController.text = '0';
                            final prefs = await SharedPreferences.getInstance(); 
                            int kodeSalesOrder = prefs.getInt('kodesalesorder') ?? 0;
                            await TrmSalesOrderDetailServices().addDetail(item.id_barang!, _budgetApproveController.text, double.parse(_discCashController.text), double.parse(_discPersenController.text), _keteranganController.text, kodeSalesOrder, _selectedValue!).then((value) {
                              setState(() {
                                isLoadSaveToCart = false;
                              });
                            });
                            await barangProvider.produkCartPopulateFromApi();
                            Navigator.pop(context);
                            Utils.showSuccessSnackBar(context: context, text: "${item.nama_barang} berhasil ditambahkan!", showLoad: false);
                          } catch (e) {
                            print(e);
                          }
                        },
                        content: Column(
                          children: [
                            isLoadSaveToCart
                            ? Container(
                                  width: AppConfig.appSize(context, .02),
                                  height: AppConfig.appSize(context, .02),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                            )
                            : Text(
                              'Update',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppConfig.appSize(context, .012),
                                // fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),
                          ],
                        ),
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget AppButtonColor({
    required Function onPressed,
    required Widget content,
    required Color color,
    required bool isEnabled,
    required BorderSide? border,
    Widget? trailingWidget
  }) {
    return ElevatedButton(
      onPressed: 
      isEnabled 
      ? () {
        onPressed.call();
      } : null,
      style: ElevatedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.appSize(context, .012)),
        ),
        elevation: 0,
        backgroundColor: color,
        side: border,
        foregroundColor: Colors.white, // Set foregroundColor to ensure text is white
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
        padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .01), vertical: AppConfig.appSize(context, .01)),
        minimumSize: Size.fromHeight(AppConfig.appSize(context, .05)),
      ),
      child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  content,
                   if (trailingWidget != null)
                   trailingWidget!
                ],
              )
            ),
           
          ],
        ),
    );
  }  

  Widget captionForm(String caption) {
    return Row(
      children: [
        AppText(text: caption,textAlign: TextAlign.left,fontSize: AppConfig.appSize(context, .012),),
      ],
    );
  }  
}
