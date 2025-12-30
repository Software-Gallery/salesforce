import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/provider/TrnSalesOrderHeaderProvider.dart';
import 'package:salesforce/provider/setting_provider.dart';
import 'package:salesforce/screens/belanja_screen.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/services/BarangService.dart';
import 'package:salesforce/services/RuteServices.dart';
import 'package:salesforce/services/TrnSalesOrderServices.dart';
import 'package:salesforce/services/auth_services.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:salesforce/widgets/TakePicture.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TambahKunjungan extends StatefulWidget {
  final String jam; 
  // final RuteItem rute;
  final bool isMasuk;
  const TambahKunjungan({super.key, required this.jam, required this.isMasuk});

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

  String jamMasuk = '';

  bool loadMulai = false;
  bool loadKirim = false;
  bool isCartLoad = false;

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final ruteProvider = Provider.of<RuteProvider>(context, listen: false);
        if (ruteProvider.ruteCurrent != null || ruteProvider.ruteCurrent!.id_absen != -1) {
          setState(() {
            isCartLoad = true;
          });          
          final barangProvider = Provider.of<BarangProvider>(context, listen: false);
          await barangProvider.produkCartPopulateFromApi().then((value) async {
            await Future.delayed(Duration(milliseconds: 500)).then((value) {
              setState(() {
                isCartLoad = false; 
              });
            });
          });     
        }
      } catch (e) {
        print(e.toString());
      }
  });
  }  

  Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      jamMasuk = prefs.getString('jam') ?? '';
    });
    if (widget.isMasuk) {
      await _takePicture();
      await loadAlamat();
    } else {
      await _loadSavedImage();
      setState(() {
        alamatName = 'test';
      });
    }    
  }

  Future<void> loadAlamat() async {
      await _getUserLocation();
      Position? posUser = await Geolocator.getLastKnownPosition();
      if (posUser != null) {
        await getAlamatName(posUser);
      }    
  }

  File? _foto;

  Future<void> _loadSavedImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'temp.jpg'; // Ganti dengan nama file yang sesuai
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      if (await file.exists()) {
        setState(() {
          _foto = file;  // Menyimpan file yang ditemukan ke dalam _foto
        });
      } else {
        print("File tidak ditemukan");
      }
    } catch (e) {
      print('Gagal memuat gambar: $e');
    }
  }

  Future<void> _takePicture() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Mengecek apakah jamMasuk kosong
    if (jamMasuk != '') return;
    
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    
    // Meminta izin kamera
    final status = await Permission.camera.request();
    if (status.isDenied) {
      Utils.showActionSnackBar(
        context: context,
        showLoad: false,
        text: "Izin Kamera diperlukan untuk menggunakan fitur ini.",
      );
      return;
    }
    
    // Menavigasi ke layar pengambilan gambar
    final returnedImage = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(camera: firstCamera),
      ),
    );

    // Jika tidak ada gambar yang dipilih
    if (returnedImage == null) {
      Navigator.pop(context);
      // Navigator.pushReplacement(
      //   context,
      //   PageRouteBuilder(
      //     pageBuilder: (context, animation, secondaryAnimation) => DashboardScreen(),
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       var begin = Offset(0.0, 1.0);
      //       var end = Offset.zero;
      //       var curve = Curves.easeInOut;

      //       var tween = Tween<Offset>(begin: begin, end: end).chain(CurveTween(curve: curve));
      //       var slideAnimation = animation.drive(tween);

      //       return SlideTransition(
      //         position: slideAnimation,
      //         child: child,
      //       );
      //     },
      //   ),
      // );
    } else {
      // Mengambil file gambar dan menyimpannya di direktori aplikasi
      setState(() {
        _foto = File(returnedImage);
      });

      // Simpan foto di folder aplikasi
      await _saveImage(returnedImage);
    }
  }

  // Fungsi untuk menyimpan foto ke folder aplikasi
  Future<void> _saveImage(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();  // Mendapatkan direktori aplikasi
      final fileName = 'temp.jpg';  // Nama file unik
      final file = File('${directory.path}/$fileName');

      // Salin gambar ke direktori aplikasi
      await File(imagePath).copy(file.path);

      print('Gambar disimpan di: ${file.path}');
    } catch (e) {
      print('Gagal menyimpan gambar: $e');
    }
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
    return Consumer4<RuteProvider, TrmSalesOrderHeaderProvider, BarangProvider, SettingProvider>(
      builder: (context, ruteProvider, trmSalesOrderHeaderProvider, barangProvider, settingProvider, child) {  
      return WillPopScope(
      onWillPop: 
      ruteProvider.ruteCurrent!.jam_masuk != ''
      ? null
      : () async {
        bool? shouldPop;
        await QuickAlert.show(
          context: context,
          type: QuickAlertType.confirm,
          text: 'Yakin ingin keluar, perubahan akan hilang',
          onCancelBtnTap: ()  {shouldPop= false; Navigator.pop(context);},
          onConfirmBtnTap: ()  {shouldPop= true; Navigator.pop(context);},
          confirmBtnText: 'Ya',
          cancelBtnText: 'Tidak',
          confirmBtnColor: Colors.green,
        );
        print(shouldPop);
        return shouldPop ?? false;
      },
      child: Scaffold(
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
                const SizedBox(height: 8),

                // Nama toko
                AppText(text: ruteProvider.ruteCurrent!.nama_customer, fontSize: AppConfig.appSize(context, .024),fontWeight: FontWeight.bold,),
                // AppText(text: "9 - BABY SHOP / TOKO SUSU",fontSize: AppConfig.appSize(context, .012),fontWeight: FontWeight.bold,),
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
                                ruteProvider.ruteCurrent!.jam_masuk != '' ? ruteProvider.ruteCurrent!.jam_masuk : '-',
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
                const Text("Keterangan", style: TextStyle(fontWeight: FontWeight.bold)),
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
                            'Lorem Ipsum DolorSit AmetLoIpsum asDolsor SLoremasasdasd Ipsum, Dolor',
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
                          widget.isMasuk ? alamatName : ruteProvider.ruteCurrent!.alamat,
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
                // barangProvider.itemCartLists.length <= 0
                // ? Container()
                // : 
                ruteProvider.ruteCurrent!.jam_masuk == ''
                ? Container()
                : GestureDetector(
                  onTap: () {
                    try {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) =>
                              BelanjaScreen(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            // Mengatur animasi slide
                            var begin = Offset(1.0, 0.0);
                            var end = Offset.zero;
                            var curve = Curves.easeInOut;
                            var tween = Tween<Offset>(begin: begin, end: end)
                                .chain(CurveTween(curve: curve));
                            var slideAnimation = animation.drive(tween);
                            return SlideTransition(
                              position: slideAnimation,
                              child: child,
                            );
                          },
                        ),
                      ).then((_) async {
                        await barangProvider.produkCartPopulateFromApi();
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Row(
                    children: [
                      Text("Produk yang dipilih", style: TextStyle(fontWeight: FontWeight.bold)),                    
                      Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: AppConfig.appSize(context, .01),),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tambah Barang",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: AppConfig.appSize(context, .012),
                                color: AppColors.accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SvgPicture.asset(
                              'assets/svg/add.svg',
                              // height: AppConfig.appSize(context, .018),
                              color: AppColors.accentColor,
                              height: 16,
                            ),                                   
                          ],
                        )
                      ),                                
                    ],
                  ),
                ),
                SizedBox(height: AppConfig.appSize(context, .005),),
                ruteProvider.ruteCurrent!.jam_masuk == ''
                ? Container()
                : 
                settingProvider.isImageItem
                ?      Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 180,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: barangProvider.itemCartLists.length + 1, // Hanya menambah 1 untuk item "Tambah"
                              itemBuilder: (context, index) {
                                if (index < barangProvider.itemCartLists.length) {
                                  // Menampilkan item dari cart
                                  return Container(
                                    width: 120,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Image.network(
                                          barangProvider.itemCartLists[index].gambar == '' ? "${AppConfig.api_ip}/storage/not-found.png" : "${AppConfig.api_ip}/storage/${barangProvider.itemCartLists[index].gambar}",
                                          height: 80,
                                        ),
                                        const SizedBox(height: 8),
                                        Text("${barangProvider.itemCartLists[index].nama_barang} x${barangProvider.itemCartLists[index].qty_kecil.toInt()}", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                                        Text(AppConfig.formatNumber(barangProvider.itemCartLists[index].harga), style: TextStyle(color: AppColors.secondaryColor, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  );
                                } else {
                                  return GestureDetector(
                                    onTap: () {
                                      try {
                                        Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) => BelanjaScreen(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              // Mengatur animasi slide
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
                                          await barangProvider.produkCartPopulateFromApi();
                                        });
                                      } catch (e) {
                                        print(e); 
                                      }
                                    },
                                    child: DottedBorder(
                                      options: RoundedRectDottedBorderOptions(
                                        radius: Radius.circular(AppConfig.appSize(context, 0.015)),
                                        dashPattern: [5, 5],
                                        color: AppColors.accentColor,
                                        strokeWidth: 2,
                                      ),
                                      child: Container(
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(AppConfig.appSize(context, .02)),
                                        ),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/svg/add.svg",
                                              width: AppConfig.appSize(context, .04),
                                              color: AppColors.accentColor,
                                            ),    
                                            Text(
                                              'Tambah',
                                              style: TextStyle(
                                                fontSize: AppConfig.appSize(context, .012),
                                                color: AppColors.accentColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),

                        ),
                      ],
                    )
                : StaggeredGrid.count(
                    crossAxisCount: 1,
                    children: [
                      ...barangProvider.itemCartLists.map<Widget>((item) {
                        bool isLast = barangProvider.itemCartLists.last == item;
                        return GestureDetector(
                          onTap: () {
                            changeQtySheet(item, barangProvider);
                          },
                          child: Container(
                            // margin: EdgeInsets.only(left: AppConfig.appSize(context, .02), right: AppConfig.appSize(context, .02)),
                            padding: EdgeInsets.only(top: AppConfig.appSize(context, .01), bottom: AppConfig.appSize(context, .005)),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isLast
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
                                        item.nama_barang,
                                        // "${item.nama_barang.length > 25 ? item.nama_barang.substring(0, 25) : item.nama_barang}",
                                        style: TextStyle(
                                          fontSize: AppConfig.appSize(context, .014),
                                          fontWeight: FontWeight.bold,
                                        ),
                                        softWrap: true, // Allow text to wrap
                                        maxLines: null, // Allow unlimited lines
                                      ),
                                      AppText(
                                        text: "${item.kode_barang}",
                                        color: AppColors.darkGrey,
                                        fontSize: AppConfig.appSize(context, .012),
                                        fontWeight: FontWeight.bold,
                                      ),                               
                                    ],
                                  ),
                                ),
                                SizedBox(width: AppConfig.appSize(context, .02)),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
                                  children: [
                                    AppText(
                                      text: "${item.qty_besar.toInt()}.${item.qty_tengah.toInt()}.${item.qty_kecil.toInt()}",
                                      color: const Color.fromARGB(255, 123, 169, 77),
                                      fontWeight: FontWeight.bold,
                                      fontSize: AppConfig.appSize(context, .013),
                                    ),
                                    AppText(
                                      text: "${AppConfig.formatNumber(item.harga.toDouble())}",
                                      fontSize: AppConfig.appSize(context, .013),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    item.disc_cash+item.disc_perc > 0
                                    ? RichText(
                                      text: TextSpan(
                                        // text: 'disc',
                                        children: [
                                          item.disc_cash > 0
                                          ? TextSpan(
                                            text: AppConfig.formatNumber(item.disc_cash),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: AppConfig.appSize(context, .012),
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ) : TextSpan(),
                                          item.disc_perc > 0
                                          ? TextSpan(
                                            text: " ${item.disc_cash>0 ? '+' : ''} ${item.disc_perc.toInt()}%",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: AppConfig.appSize(context, .012),
                                              // fontWeight: FontWeight.bold,
                                            ),
                                          ) : TextSpan(),
                                        ],
                                      ),
                                    ) : Container(),
                                    SizedBox(height: AppConfig.appSize(context, .005),),
                                    AppText(
                                      text: "${AppConfig.formatNumber(item.total.toDouble())}",
                                      fontSize: AppConfig.appSize(context, .015),
                                      fontWeight: FontWeight.bold,
                                    ),                                    
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                // barangProvider.itemCartLists.length <= 0 
                // ? Container()
                // : 
                Column(
                  children: [
                    // Divider(
                    //   thickness: 2,
                    //   color:  AppColors.darkGrey.withOpacity(.3),
                    // ),
                    // Container(
                    //   padding: EdgeInsets.only(top: AppConfig.appSize(context, .01)),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         'Subtotal',
                    //         style: TextStyle(fontSize: AppConfig.appSize(context, .013), fontWeight: FontWeight.bold, color: AppColors.darkGrey),
                    //       ),
                    //       Text(
                    //       AppConfig.formatNumber(barangProvider.subtotaltambah),
                    //         style: TextStyle(fontSize: AppConfig.appSize(context, .015), fontWeight: FontWeight.bold,),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   padding: EdgeInsets.only(top: AppConfig.appSize(context, .01), bottom: AppConfig.appSize(context, .01)),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Text(
                    //         'Diskon',
                    //         style: TextStyle(fontSize: AppConfig.appSize(context, .013), fontWeight: FontWeight.bold, color: AppColors.darkGrey),
                    //       ),
                    //       Text(
                    //         AppConfig.formatNumber(barangProvider.subtotaltambah - barangProvider.totaltambah),
                    //         style: TextStyle(fontSize: AppConfig.appSize(context, .015), fontWeight: FontWeight.bold,),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Divider(
                      thickness: 2,
                      color: AppColors.darkGrey.withOpacity(.1),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: AppConfig.appSize(context, .01), bottom: AppConfig.appSize(context, .02)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(fontSize: AppConfig.appSize(context, .013), fontWeight: FontWeight.bold, color: AppColors.darkGrey),
                          ),
                          Text(
                            AppConfig.formatNumber(barangProvider.totaltambah),
                            style: TextStyle(fontSize: AppConfig.appSize(context, .016), fontWeight: FontWeight.bold,),
                          ),
                        ],
                      ),
                    ),                    
                  ],
                ),
                ruteProvider.ruteCurrent!.jam_masuk == ''
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
                          isLoad: loadMulai,
                          label: 'Mulai',
                          fontWeight: FontWeight.w600,
                          padding: EdgeInsets.symmetric(vertical: 30),
                          onPressed: () async {
                            try {
                              setState(() {
                                loadMulai = true;
                              });
                              final prefs = await SharedPreferences.getInstance(); 
                              int kodeSalesOrder = await TrmSalesOrderDetailServices().addHeader(ruteProvider.ruteCurrent!.id_departemen, ruteProvider.ruteCurrent!.id_customer, _keteranganController.text);
                              prefs.setInt('kodesalesorder', kodeSalesOrder);
                              int? saveIdAbsen = await RuteServices.addAbsen(
                                ruteProvider.ruteCurrent!.id_customer, 
                                ruteProvider.ruteCurrent!.id_departemen, 
                                DateFormat('yyyy-MM-dd').format(DateTime.now()),
                                DateFormat('HH:mm:ss').format(DateTime.now()),
                                latt,
                                longt,
                                _keteranganController.text,
                                alamatName,
                                ruteProvider.ruteCurrent!.tipe);
                              prefs.setInt('idAbsen', saveIdAbsen);
                              await AuthService().getCurrentNoVisit(context);
                              // await loadAll();
                              setState(() {
                                loadMulai = false;
                              });
                            } catch (e) {
                              setState(() {
                                loadMulai = false;
                              });                              
                              Utils.showActionSnackBar(context: context, text: e.toString(), showLoad: false);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )
                :
                Container(
                  child: AppButton(
                    isLoad: loadKirim,
                    label: 'Kirim',
                    fontWeight: FontWeight.w600,
                    padding: EdgeInsets.symmetric(vertical: 30),
                    onPressed: () async {
                      try {
                        setState(() {
                          loadKirim = true;
                        });
                        await kirimVisit();
                        final prefs = await SharedPreferences.getInstance(); 
                        int kodeSalesOrder = prefs.getInt('kodesalesorder') ?? 0;
                        await RuteServices.selesaiAbsen(kodeSalesOrder);
                        // await TrmSalesOrderDetailServices().addDetail(kodeSalesOrder);                        
                        await RuteServices().sendImageToServer(_foto!, kodeSalesOrder.toString());
                        prefs.setInt('idAbsen', -1);
                        prefs.setInt('kodesalesorder', 0);
                        setState(() {
                          loadKirim = false;
                        });
                        // Navigator.pop(context);
                        Utils.showSuccessSnackBar(context: context, text: "Berhasil menyelesaikan kunjungan", showLoad: false);
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
                      } catch (e) {
                        setState(() {
                          loadKirim = false;
                        });
                        Utils.showActionSnackBar(context: context, text: e.toString(), showLoad: false);
                      }
                    },
                  ),
                ),
                SizedBox(height: AppConfig.appSize(context, .02),),                
              ],
            ),
          ),      
        ));
      }
    );    
  }

  Widget padded(Widget widget) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)),
      child: widget,
    );
  }  

  Future<void> changeQtySheet(BarangItem item, BarangProvider barangProvider) async {
    TextEditingController _budgetApproveController = TextEditingController();
    TextEditingController _discCashController = TextEditingController();
    TextEditingController _discPersenController = TextEditingController();
    TextEditingController _keteranganController = TextEditingController();
    bool isLoadSaveToCart = false;
    bool isLoadDeleteCart = false;
    BarangItem barang = barangProvider.itemCartLists.firstWhere(
      (brg) => brg.id_barang == item.id_barang, 
      orElse: () => BarangItem(id_barang: -1, kode_barang: '1', id_departemen: 1, nama_barang: '', satuan_besar: 1, satuan_tengah: 1, satuan_kecil: 0, konversi_besar: 0, konversi_tengah: 0, gambar: '', is_aktif: 1, harga: 0, qty_besar: 0, qty_tengah: 0, qty_kecil: 0, disc_cash: 0, disc_perc: 0, ket_detail: '', subtotal: 0, total: 0),
    );
    String recentQty = barangProvider.loadQty(item.id_barang!);
    _budgetApproveController.text=recentQty;
    _discCashController.text="${barang.disc_cash.round()}";
    _discPersenController.text="${barang.disc_perc.round()}";
    _keteranganController.text="${barang.ket_detail}";
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
            height: AppConfig.appSize(context, .41),
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
                  SizedBox(height: AppConfig.appSize(context, .02)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConfig.appSize(context, .024),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            // padding: EdgeInsets.symmetric(horizontal: 10,),
                            child: AppButtonColor(
                              border: null,
                              isEnabled: true,
                              onPressed: () async {
                                final result = await showModalBottomSheet<bool>(
                                  context: context,
                                  isDismissible: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  builder: (context) {
                                    return Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.delete_outline,
                                            size: 48,
                                            color: Colors.red,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            "Hapus produk dari keranjang?",
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "Yakin ingin menghapus ${item.nama_barang}?",
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: AppButtonColor(
                                                  border: BorderSide(color: Colors.red, width: 1),
                                                  isEnabled: true,
                                                  onPressed: () => Navigator.pop(context, false),
                                                  content: Text(
                                                    'Batal',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: AppConfig.appSize(context, .012),
                                                      // fontWeight: FontWeight.bold,
                                                      color: Colors.red
                                                    ),
                                                  ),
                                                  color: Colors.white,
                                                ),
                                              ),          
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: AppButtonColor(
                                                  border: null,
                                                  isEnabled: true,
                                                  onPressed: () => Navigator.pop(context, true),
                                                  content: Text(
                                                    'Hapus',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: AppConfig.appSize(context, .012),
                                                      // fontWeight: FontWeight.bold,
                                                      color: Colors.white
                                                    ),
                                                  ),
                                                  color: Colors.red,
                                                ),
                                              ),        
                                            ],
                                          ),
                                          SizedBox(height: 10,)
                                        ],
                                      ),
                                    );
                                  },
                                );
                                if (result != true) return;
                                try {
                                  setState(() => isLoadDeleteCart = true);
                                  await BarangService().removeBarangKeranjang(item.id_barang!);
                                  setState(() => isLoadDeleteCart = false);
                                  await barangProvider.produkCartPopulateFromApi();
                                  Navigator.pop(context); 
                                  Utils.showInfoSnackBar(
                                    context: context,
                                    text: "${item.nama_barang.length > 20 ? item.nama_barang.substring(0, 20) : item.nama_barang}... Sudah Dihapus!",
                                    showLoad: false,
                                  );
                                } catch (e) {
                                  setState(() => isLoadDeleteCart = false);
                                  print(e);
                                }
                              },

                              content: Column(
                                children: [
                                  isLoadDeleteCart
                                  ? Container(
                                        width: AppConfig.appSize(context, .02),
                                        height: AppConfig.appSize(context, .02),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                  )
                                  : Text(
                                    'Hapus',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: AppConfig.appSize(context, .012),
                                      // fontWeight: FontWeight.bold,
                                      color: Colors.white
                                    ),
                                  ),
                                ],
                              ),
                              color: Colors.red,
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        Expanded(
                          child: Container(
                            // padding: EdgeInsets.symmetric(horizontal: 10,),
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
                                  await TrmSalesOrderDetailServices().addDetail(item.id_barang!, _budgetApproveController.text, double.parse(_discCashController.text), double.parse(_discPersenController.text), _keteranganController.text, kodeSalesOrder).then((value) {
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
                        ),
                      ],
                    )
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