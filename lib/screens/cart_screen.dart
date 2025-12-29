import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/chart_item_widget.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/helpers/column_with_seprator.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/screens/barang_details_screen.dart';
import 'package:salesforce/services/BarangService.dart';
import 'package:salesforce/styles/colors.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  Widget barangGrid = Center(child: Text('Belum Ada Promo'),);
  bool bestDealSlideLoad = true;

  // Widget : CartGridWidget - Tampilan row item di Daftar Belanja
  // -------------------------------------------------------------------------------------------
  Widget cartGridWidget(BuildContext context) {
    return Consumer<BarangProvider>(
      builder: (context, barangProvider, child) {
        if (barangProvider.itemCartLists.isEmpty) {
          return SizedBox(height: AppConfig.appSize(context, .2), child: Center(child:  Text(AppLocalizations.of(context)!.cart_is_empty))); // Menangani kasus keranjang kosong
        }
        return Column(
          children: getChildrenWithSeperator(
            addToLastChild: false,
            widgets: barangProvider.itemCartLists.map((e) {
              return  GestureDetector(
                onTap: () {
                  onItemClicked(context, e);
                }, 
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppConfig.appSize(context, .025),
                  ),
                  width: double.maxFinite,
                  child: ChartItemWidget(
                      item: e,
                      qty: e.qty_kecil,
                      isItemLast: e == barangProvider.itemCartLists.last,
                      onCloseTap: (idBarang) => onCloseTap(idBarang), // Pastikan fungsi onCloseTap didefinisikan
                    ),
                )
              );
            }).toList(),
            seperator: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppConfig.appSize(context, .02),
              ),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
        );
      },
    );
  }
  
  // Fungsi : Saat tekan icon X, hapus dari Daftar Belanja
  void onCloseTap(int idBarang) {
    showDialog(
      context: context,
      barrierDismissible: false, // Dialog tidak akan tertutup saat di luar dialog di-tap
      builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Kurangi radius
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Membuat kolom mengikuti ukuran konten
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hapus produk dari keranjang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppConfig.appSize(context, .015),
              ),
            ),
            SizedBox(height: AppConfig.appSize(context, .01)), // Jarak antar teks
            Text(
              'Kamu yakin ingin menghapus produk ini?',
              style: TextStyle(
                fontSize: AppConfig.appSize(context, .012),
              ),
            ),
          ],
        ), // Pesan dialog
        actionsPadding: EdgeInsets.zero, // Hilangkan padding default
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(
              left: AppConfig.appSize(context, .015),
              right: AppConfig.appSize(context, .015),
              bottom: AppConfig.appSize(context, .015),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Aksi saat tombol "Batal" ditekan
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.accentColor), // Border warna
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.0), // Tinggi tombol
                      foregroundColor: AppColors.accentColor, // Warna teks putih
                    ),
                    child: Text('Batal', style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                ),
                SizedBox(width: AppConfig.appSize(context, .015)), // Jarak antar tombol
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        setState(() {
                          bestDealSlideLoad=true;
                        });
                        final barangProvider = Provider.of<BarangProvider>(context, listen: false);
                        Navigator.pop(context);
                        // await BarangService().removeBarangCart(idBarang);
                        barangProvider.removeCart(idBarang);
                      } catch (e) {
                        Utils.showActionSnackBar(context: context,showLoad: true,text: e.toString());
                      } finally {
                        setState(() {
                          bestDealSlideLoad=false;
                          barangGrid=cartGridWidget(context);
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentColor, // Warna background penuh
                      foregroundColor: Colors.white, // Warna teks putih
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.0), // Tinggi tombol
                    ),
                    child: Text(
                      'Ya, Hapus',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
    );
  }
  // -------------------------------------------------------------------------------------------
  
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final barangProvider = Provider.of<BarangProvider>(context, listen: false);
        barangProvider.produkCartPopulateFromApi().then((value) {
          setState(() {
            bestDealSlideLoad = false;
            barangGrid = cartGridWidget(context);
          });
        }); 
        // barangProvider.hitungTotal();
      } catch (e) {
        print(e.toString());
      }
    });
  }

  void onItemClicked(BuildContext context, BarangItem barangItem) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BarangDetailsScreen(
            barangItem,
            false,
            heroSuffix: "cart_screen",
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BarangProvider>(
      builder: (context, barangProvider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white), 
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            title: Container(
              child: AppText(
                text: AppLocalizations.of(context)!.cart_title,
                fontWeight: FontWeight.bold,
                fontSize: AppConfig.appSize(context, .016),
                color: Colors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  bestDealSlideLoad 
                  ? SizedBox(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                      height: AppConfig.appSize(context, .2),
                    )
                  : barangGrid,
                  getCheckoutButton(context)
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget getCheckoutButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: AppButton(
        label: 'Kembali ke Kunjungan',
        fontWeight: FontWeight.w600,
        padding: EdgeInsets.symmetric(vertical: 30),
        // trailingWidget: getButtonPriceWidget(),
        onPressed: () {
          // showBottomSheet(context);
        },
      ),
    );
  }

  Widget getButtonPriceWidget() {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Color(0xff489E67),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        "\$12.96",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
