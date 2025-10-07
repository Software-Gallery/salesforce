import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/provider/CurrentVisitProvider.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:salesforce/widgets/TakePicture.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TambahKunjungan extends StatefulWidget {
  final String noVisit;
  final String jam;
  const TambahKunjungan({super.key, required this.noVisit, required this.jam});

  @override
  State<TambahKunjungan> createState() => _TambahKunjunganState();
}

class _TambahKunjunganState extends State<TambahKunjungan> {

  TextEditingController _searchController = TextEditingController();  
  TextEditingController _keteranganController = TextEditingController();  
  late FocusNode _focusNodeSearch;  
  late FocusNode _focusNodeKeterangan;  

  String alamatName = "";
  List<Placemark> placemarks = [];

  String latt = "";
  String longt = "";

  @override
  void initState() {
    super.initState();
    _focusNodeSearch = FocusNode();
    _focusNodeSearch.addListener(() {
      setState(() {});
    });
    _focusNodeKeterangan = FocusNode();
    _focusNodeKeterangan.addListener(() {
      setState(() {});
    });
    setState(() {
      _keteranganController.text= '';
    });
    loadAll();
  }  

  Future<void> loadAll() async {
    await _takePicture();
    await loadAlamat();
  }

  Future<void> loadAlamat() async {
      await _getUserLocation();
      Position? posUser = await Geolocator.getLastKnownPosition();
      if (posUser != null) {
        await getAlamatName(posUser);
      }    
  }

  File? _foto;
  Future<void> _takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    final prefs = await SharedPreferences.getInstance();
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    final status = await Permission.camera.request();
    if (status.isDenied) {
      Utils.showActionSnackBar(context: context, showLoad: false, text: "Izin Kamera diperlukan untuk menggunakan fitur ini. ",);
      return;
    }
    final returnedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(
          camera: firstCamera,
        ),
      ),
    ).then((value) {
      if (value == null) {
        // Navigator.popUntil(this.context, (route) => route.isFirst);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              // Mengatur animasi slide
              var begin = Offset(0.0, 1.0);
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
      } else {
        setState(() {
          _foto = File(value);
        });
      }
    });
  }     


  Future<Position?> getLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    if (position.isMocked == false) {
      return position;
    } else {
      return null;
    }
  }

  _getUserLocation() async {
    var status = await Permission.location.status;

    var isEnable = true;

    if (status.isDenied || status.isPermanentlyDenied) {
      isEnable = await checkPermission();
      return null;
    }

    if (isEnable) {
      Position? location = await getLocation();

      if (location == null) {
        Utils.showActionSnackBar(context: context, text: "Anda sedang menggunakan Mock GPS, Lokasi Anda tidak akurat!", showLoad: true);    
        return;
      }

      setState(() {
        latt = location!.latitude.toString();
        longt = location!.longitude.toString();
      });

      return location!;
    } else {
      return null;
    }
  }  

  Future<bool> checkPermission() async {
    final status = await Permission.location.request();

    if (status.isDenied) {
      Utils.showActionSnackBar(context: context, text: "Izin Lokasi diperlukan untuk menggunakan fitur ini. ", showLoad: true);
      return false;
    }

    if (status.isPermanentlyDenied) {
      Navigator.of(context).pop();
      return false;
    }
    return true;
  }

  Future<String> getAlamatName(Position positionUser) async {
    try {
      // List<Placemark> getplacemarks = await placemarkFromCoordinates(
      //     positionUser.latitude, positionUser.longitude,
      //     localeIdentifier: "id_ID");
      List<Placemark> getplacemarks = await placemarkFromCoordinates(
          positionUser.latitude, positionUser.longitude,);      
      setState(() {
        placemarks.clear();
        placemarks.addAll(getplacemarks);
      });
      Placemark place = placemarks[0];
      setState(() {
        alamatName = "${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}" ?? '';
      });
      return "${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}" ??
          '';
    } catch (e) {
      throw ('Gagal Menentukan Alamat, Periksa Koneksi Internet Dan Coba Kembali Nanti');
    }
  }    

  Future<void> saveVisit(String p_noVisit, String p_jam) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('noVisit', p_noVisit);
    prefs.setString('jam', p_jam);
  }

  Future<void> kirimVisit() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('noVisit', '');
    prefs.setString('jam', '');
  }  

  @override
  Widget build(BuildContext context) {
    return Consumer<CurrentVisitProvider>(
      builder: (context, currentVisitProvider, child) {  
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(color: Colors.white), 
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            title: Container(
              child: AppText(
                text: 'Kunjungan',
                fontWeight: FontWeight.bold,
                fontSize: AppConfig.appSize(context, .016),
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search toko
                const SizedBox(height: 16),
                // TextFormField(
                //   onEditingComplete: () {
                //     setState(() {
                //       _searchController.text =
                //           _searchController.text.toUpperCase();
                //     });
                //   },
                //   onTapOutside: (event) {
                //     setState(() {
                //       _searchController.text =
                //           _searchController.text.toUpperCase();
                //     });
                //     _focusNodeSearch.unfocus();
                //   },
                //   controller: _searchController,
                //   focusNode: _focusNodeSearch,
                //   decoration: InputDecoration(
                //     prefixIcon:           SvgPicture.asset(
                //       "assets/icons/search_icon.svg",
                //       color: AppColors.secondaryColor,
                //       fit: BoxFit.scaleDown,
                //     ),
                //     filled: !_focusNodeSearch.hasFocus,
                //     fillColor: AppColors.grey,
                //     // label: Text('Jam Server'),
                //     hintText: 'Cari Toko',
                //     hintStyle: TextStyle(
                //         color: Colors.grey.shade600,
                //         fontWeight: FontWeight.w400),
                //     focusedBorder: OutlineInputBorder(
                //         borderRadius:
                //             BorderRadius.all(Radius.circular(10)),
                //         borderSide: _focusNodeSearch.hasFocus
                //             ? BorderSide(
                //                 color: Colors.black,
                //                 width: 2.0,
                //               )
                //             : BorderSide.none),
                //     enabledBorder: OutlineInputBorder(
                //         borderRadius:
                //             BorderRadius.all(Radius.circular(10)),
                //         borderSide: _focusNodeSearch.hasFocus
                //             ? BorderSide(
                //                 color: Colors.black,
                //                 width: 2.0,
                //               )
                //             : BorderSide.none),
                //   ),
                // ),
                // const SizedBox(height: 16),

                // Nomor + Extra Call
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("#12345", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AppText(text: 'Extra Call',color: Colors.red, fontSize: AppConfig.appSize(context, .012),),
                    )
                  ],
                ),
                const SizedBox(height: 8),

                // Nama toko
                AppText(text: "PT. INI DATA TEST",fontSize: AppConfig.appSize(context, .024),fontWeight: FontWeight.bold,),
                AppText(text: "9 - BABY SHOP / TOKO SUSU",fontSize: AppConfig.appSize(context, .012),fontWeight: FontWeight.bold,),
                const SizedBox(height: 8),

                // Button riwayat transaksi
                // ElevatedButton(
                //   onPressed: () {},
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: Colors.orange[100],
                //     foregroundColor: Colors.orange,
                //   ),
                //   child: const Text("Riwayat Transaksi"),
                // ),
                // const SizedBox(height: 16),

                Container(
                  // height: _height * 0.3,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 100, // Lebar kotak untuk check-in
                          height: 100, // Warna kotak untuk check-in
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Jam Masuk',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                widget.jam,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white),
                              ),
                            ],
                          )),
                        ),
                      ),
                      const VerticalDivider(
                        // Garis vertical sebagai pemisah
                        color: Colors.black,
                        thickness: 2.0,
                        width: 4, // Lebar garis
                      ),
                      Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 100, // Lebar kotak untuk check-in
                          height: 100, // Warna kotak untuk check-in
                          child: Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Jam Keluar',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              Text(
                                "-",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: Colors.white),
                              ),
                            ],
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Info kunjungan
                // Row(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     Expanded(
                //       flex: 1,
                //       child: Text(
                //         "Kunjungan Terakhir: 22/06/2020",
                //         softWrap: true,
                //         overflow: TextOverflow.visible,
                //       ),
                //     ),
                //     Expanded(
                //       flex: 1,
                //       child: Text(
                //         "Total Kunjungan: 2",
                //         softWrap: true,
                //         overflow: TextOverflow.visible,
                //         textAlign: TextAlign.right, // biar rata kanan
                //       ),
                //     ),
                //   ],
                // ),

                // const SizedBox(height: 16),

                // Alasan
                const Text("KETERANGAN", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextFormField(
                  onTapOutside: (event) {
                    _focusNodeKeterangan.unfocus();
                  },
                  maxLines: null,
                  minLines: null,
                  controller: _keteranganController,
                  focusNode: _focusNodeKeterangan,
                  decoration: InputDecoration(
                    filled: !_focusNodeKeterangan.hasFocus,
                    fillColor: AppColors.grey,
                    // label: Text('Jam Server'),
                    hintText: 'Keterangan',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                        borderSide: _focusNodeKeterangan.hasFocus
                            ? BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              )
                            : BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.all(Radius.circular(10)),
                        borderSide: _focusNodeKeterangan.hasFocus
                            ? BorderSide(
                                color: Colors.black,
                                width: 2.0,
                              )
                            : BorderSide.none),
                  ),
                ),
                const SizedBox(height: 8),
                SkeletonLoader(
                  isLoading: alamatName == '',
                  skeleton: Skeletonizer(
                    effect: ShimmerEffect(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.white,
                      duration: Duration(milliseconds: 1200),
                    ),
                    child: Table(
                      columnWidths: const {
                        0: IntrinsicColumnWidth(), // Label
                        1: FixedColumnWidth(20),      // Nilai data, agar auto wrap
                        2: FlexColumnWidth(),      // Nilai data, agar auto wrap
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.top,
                      children: [
                        TableRow(
                          children: [
                            SvgPicture.asset("assets/svg/map.svg",width: AppConfig.appSize(context, .03),),              
                            Text(''),
                            Text(
                            'Lorem Ipsum DolorSit AmetLorem Ipsum Dolor SLorem Ipsum, Dolor',
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,),
                            ),
                          ],
                        ),
                      ]
                    ),                                       
                  ),
                  child: Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(), // Label
                      1: FixedColumnWidth(20),      // Nilai data, agar auto wrap
                      2: FlexColumnWidth(),      // Nilai data, agar auto wrap
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.top,
                    children: [
                      TableRow(
                        children: [
                          SvgPicture.asset("assets/svg/map.svg",width: AppConfig.appSize(context, .03),),              
                          Text(''),
                          Text(
                          alamatName,
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,),
                          ),
                        ],
                      ),
                    ]
                  ),             
                ),       
                const SizedBox(height: 16),

                // Pilih Produk
               
                const SizedBox(height: 8),
                currentVisitProvider.noVisit == '' 
                ? Container()
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Produk yang dipilih", style: TextStyle(fontWeight: FontWeight.bold)),                    
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: 8,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 100,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Image.network(
                                  "https://pngimg.com/uploads/orange/orange_PNG800.png",
                                  height: 60,
                                ),
                                const SizedBox(height: 8),
                                const Text("Orange Juice", textAlign: TextAlign.center),
                                const Text("Rp 10.000", style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppConfig.appSize(context, .02),),
                currentVisitProvider.noVisit == ''
                ? Row(
                  children: [
                    Expanded( 
                      child : Container(
                        child: AppButton(
                          label: 'Batal',
                          fontWeight: FontWeight.w600,
                          padding: EdgeInsets.symmetric(vertical: 30),
                          // trailingWidget: getButtonPriceWidget(),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          isOutline: true,
                        ),
                      ),
                    ),
                    SizedBox(width: AppConfig.appSize(context, .01),),
                    Expanded( 
                      child : Container(
                        child: AppButton(
                          label: 'Mulai',
                          fontWeight: FontWeight.w600,
                          padding: EdgeInsets.symmetric(vertical: 30),
                          // trailingWidget: getButtonPriceWidget(),
                          onPressed: () async {
                            await saveVisit(widget.noVisit, widget.jam);
                            currentVisitProvider.setnoVisit(widget.noVisit);
                            currentVisitProvider.setjam(widget.jam);
                          },
                        ),
                      ),
                    ),
                  ],
                )
                :
                Container(
                  child: AppButton(
                    label: 'Kirim',
                    fontWeight: FontWeight.w600,
                    padding: EdgeInsets.symmetric(vertical: 30),
                    onPressed: () async {
                      await kirimVisit();
                      currentVisitProvider.setnoVisit('');
                      currentVisitProvider.setjam('');  
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            // Mengatur animasi slide
                            var begin = Offset(0.0, 1.0);
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
                  ),
                ),
              ],
            ),
          ),      
        );
      }
    );    
  }

  Widget padded(Widget widget) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)),
      child: widget,
    );
  }  

}