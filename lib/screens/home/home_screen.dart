import 'package:flutter/material.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/helpers/column_with_seprator.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/provider/TrnSalesOrderHeaderProvider.dart';
import 'package:salesforce/screens/account/auth_page.dart';
import 'package:salesforce/screens/tambah_kunjungan.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slide_digital_clock_fork/slide_digital_clock_fork.dart';
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

  late FocusNode _focusNodeSearch;

  TextEditingController _searchApproveController = TextEditingController();  
  bool isTrnLoad = true;

  @override
  void initState() {
    super.initState();
    _focusNodeSearch = FocusNode();
    _focusNodeSearch.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final trnHeaderProvider = Provider.of<TrmSalesOrderHeaderProvider>(context, listen: false);
        await trnHeaderProvider.populateFromApi().then((value) async {
          await Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
              isTrnLoad = false; 
            });
          });
        });     
      } catch (e) {
        print(e.toString());
      }
    }); 
  }
  Future<void> loadCabang() async {
    final prefs = await SharedPreferences.getInstance();
    final barangProvider = Provider.of<BarangProvider>(context, listen: false);
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

  @override
  Widget build(BuildContext context) {

    return Consumer<TrmSalesOrderHeaderProvider>(
      builder: (context, trmHeaderProvider, child) {
      return Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Localizations.override(
                    context: context,
                    locale: const Locale('en'),
                    child: Builder(
                      builder: (context) {
                        return heroWidget();
                      },
                    ),
                  ),
                  SizedBox(height: AppConfig.appSize(context, .01),),
                  padded(
                    TextFormField(
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
                      decoration: InputDecoration(
                        prefixIcon:           SvgPicture.asset(
                          "assets/icons/search_icon.svg",
                          color: AppColors.secondaryColor,
                          fit: BoxFit.scaleDown,
                        ),
                        filled: !_focusNodeSearch.hasFocus,
                        fillColor: AppColors.grey,
                        // label: Text('Jam Server'),
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400),
                        focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                            borderSide: _focusNodeSearch.hasFocus
                                ? BorderSide(
                                    color: Colors.black,
                                    width: 2.0,
                                  )
                                : BorderSide.none),
                        enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)),
                            borderSide: _focusNodeSearch.hasFocus
                                ? BorderSide(
                                    color: Colors.black,
                                    width: 2.0,
                                  )
                                : BorderSide.none),
                      ),
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
                          widgets: trmHeaderProvider.itemLists.map((e) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              width: double.maxFinite,
                              child: Skeleton.leaf(
                                child: Card(child: Text('as'),
                                ),
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
                      ),
                    ), 
                    child: 
                    trmHeaderProvider.itemLists.length <= 0
                    ? Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: AppConfig.appSize(context, .1),
                          ),
                          Text(
                            'Belum ada Upcoming visit',
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
                        widgets: trmHeaderProvider.itemLists.map((e) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            width: double.maxFinite,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => TambahKunjungan(noVisit: e.kode_sales_order!, jam: DateFormat('HH:mm:ss').format(DateTime.now()),),
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
                              child: visitCard(e.kode_sales_order!, DateTime.now(), () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => TambahKunjungan(noVisit: e.kode_sales_order!, jam: DateFormat('HH:mm:ss').format(DateTime.now()),),
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
                              }),
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
                  )
                ],
            
              ),
            ),
          ),
        ),
      );
    }); 
  }
  

  Widget visitCard(String companyName, DateTime visitDate, VoidCallback onVisit) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Kiri: Nama dan tanggal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    companyName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('d MMM y ● HH:mm', 'id').format(visitDate),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
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
  Widget heroWidget() {
    final _height=MediaQuery.of(context).size.height;
    final _width=MediaQuery.of(context).size.width;
    final String scannerIcon = "assets/icons/cart_icon.svg";
    final String favIcon = "assets/icons/favourite_icon.svg";
    final String walletIcon = "assets/icons/wallet.svg";
    return Container(
      height: AppConfig.appSize(context, .3),
      // padding: EdgeInsets.only(top: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 255, 96, 28),
            const Color.fromARGB(255, 255, 121, 31),
            const Color.fromARGB(255, 238, 133, 63),
            const Color.fromARGB(255, 246, 153, 91),
            const Color.fromARGB(255, 243, 185, 146),
            const Color.fromARGB(255, 255, 238, 226),
            Colors.white,
        ])
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/images/pattern_1.svg',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              colorBlendMode: BlendMode.overlay, 
              // color: Colors.white.withOpacity(0.1), // Optional tint
            ),
          ),             
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
                            DateFormat('EEE, d MMM y', 'id').format(DateTime.now()),
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
                          'assets/images/account_image.jpg', // CATATAN: .svg tidak didukung oleh Image.asset!
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

                padded(
                  Row(
                    children: [
                      DigitalClock(
                        hourMinuteDigitTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                        secondDigitTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        colon: Text(
                          ":",
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ],
                  )
                ),
              SizedBox(height: AppConfig.appSize(context, .004),),
              padded(
                Container(
                  padding: EdgeInsets.all(AppConfig.appSize(context, .012)),
                  width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConfig.appSize(context, .015)),
                    boxShadow: [
                      BoxShadow(color: Color(0xFF000000).withOpacity(.2),offset: Offset(0, 4), blurRadius: 10 )
                    ]
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start, 
                        children: [
                          Text(
                            "Total Visit",
                            style: TextStyle(
                                fontSize: AppConfig.appSize(context, .018),
                                fontWeight: FontWeight.w900,),
                          ),
                          Spacer(),
                          Text(
                            "${AppLocalizations.of(context)!.home_produk_slder_more}",
                            style: TextStyle(
                                fontSize: AppConfig.appSize(context, .012),
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondaryColor),
                          ),
                        ],
                      ),
                      Text(
                        "32",
                        style: TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: AppConfig.appSize(context, .04),
                            fontWeight: FontWeight.w900,),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start, 
                        children: [
                          SvgPicture.asset(
                            "assets/icons/swap.svg",
                            width: AppConfig.appSize(context, .018),
                            height: AppConfig.appSize(context, .018),
                            color: AppColors.accentColor,
                          ),
                          SizedBox(width: AppConfig.appSize(context, .01),),
                          GestureDetector(
                          child: Text(
                            totalCurrent == totalState.today ? 'Today' : totalCurrent == totalState.weekly ? 'Weekly' : totalCurrent == totalState.monthly ? 'Monthly' : '',
                            style: TextStyle(
                              fontSize: AppConfig.appSize(context, .012),
                              fontWeight: FontWeight.w900,
                              color: AppColors.accentColor
                            ),
                          ),
                          onTap: () {
                            if (totalCurrent == totalState.today) {
                              setState(() {
                                totalCurrent = totalState.weekly;
                              });
                            } else if (totalCurrent == totalState.weekly) {
                              setState(() {
                                totalCurrent = totalState.monthly;
                              });
                            } else if (totalCurrent == totalState.monthly) {
                              setState(() {
                                totalCurrent = totalState.today;
                              });
                            }
                            },
                          )
                        ],
                      ),                                 
                    ],
                  )
                )
              )
            ],
          ),       
        ],
      )
    );
  }

}
