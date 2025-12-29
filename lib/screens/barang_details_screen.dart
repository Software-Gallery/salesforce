import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/currency_input_formatter.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/screens/cart_screen.dart';
import 'package:salesforce/services/BarangService.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:salesforce/widgets/item_counter_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BarangDetailsScreen extends StatefulWidget {
  final BarangItem groceryItem;
  final String? heroSuffix;
  final bool isPromo;

  const BarangDetailsScreen(this.groceryItem, this.isPromo, {this.heroSuffix});

  @override
  _BarangDetailsScreenState createState() => _BarangDetailsScreenState();
}

class _BarangDetailsScreenState extends State<BarangDetailsScreen> {
  int amount = 1;
  // late String cabang;
  String cabang = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initCabang();
  }

  Future<void> initCabang() async {
    final prefs = await SharedPreferences.getInstance();
    String prefsCabang = prefs.getString('cabangname') ?? '';
    setState(() {
      cabang = prefsCabang;
    });
  }

  bool isLoadSaveItemDaftar = false;
  bool isLoadSaveToCart = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<BarangProvider>(
      builder: (context, barangProvider, child) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SizedBox(height: AppConfig.appSize(context, .015)),
              getImageHeaderWidget(),
              Padding(
                padding: EdgeInsets.only(
                  left: AppConfig.appSize(context, .02),
                  right: AppConfig.appSize(context, .02),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    widget.groceryItem.nama_barang,
                    style: TextStyle(
                        fontSize: AppConfig.appSize(context, .018), 
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: AppConfig.appSize(context, .02),
                  right: AppConfig.appSize(context, .02),
                ),
                child: Text(
                  "Stok : ${widget.groceryItem.qty_kecil}",
                  style: TextStyle(
                    color: AppColors.darkGrey,
                    fontWeight: FontWeight.bold,
                    fontSize: AppConfig.appSize(context, .014),
                  ),
                ),
              ),
              SizedBox(height: AppConfig.appSize(context, .005)), // Added space to avoid overflow

              Padding(
                padding: EdgeInsets.only(
                  left: AppConfig.appSize(context, .02),
                  right: AppConfig.appSize(context, .02),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ItemCounterWidget(
                      onAmountChanged: (newAmount) {
                        setState(() {
                          amount = newAmount;
                        });
                      },
                      qty: 1,
                      maxQty: widget.groceryItem.qty_kecil,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          AppConfig.formatNumber(getTotalPromoPrice()),
                          style: TextStyle(
                            fontSize: AppConfig.appSize(context, .02),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Divider(thickness: 1),
              SizedBox(height: AppConfig.appSize(context, .018)),
              Padding(
                padding: EdgeInsets.only(
                  left: AppConfig.appSize(context, .02),
                  right: AppConfig.appSize(context, .02),
                ),
                child: Row(
                  children: [
                    // AppButton(
                    //   label: "Tambah ke Daftar Belanja",
                    //   onPressed: ()  {
                    //     // int newQty = (barangCart.isEmpty || barangCart == {} ? 0 : barangCart['qty']); 
                    //     // int newQty = amount;
                    //     // cartProvider.addCart(widget.groceryItem.id!, newQty, context);
                    //   },
                    // ),
                    // SizedBox(width: AppConfig.appSize(context, .02),),
                    // AppButton(
                    //   label: "Tambah ke Keranjang",
                    //   onPressed: ()  {
                    //     // int newQty = (barangCart.isEmpty || barangCart == {} ? 0 : barangCart['qty']); 
                    //     int newQty = amount;
                    //     cartProvider.addCart(widget.groceryItem.id!, newQty, context);
                    //   },
                    // ),
                    getAddCart(
                      context,() async {
                        try {
                          setState(() {
                            isLoadSaveToCart = true;
                          });
                          int newQty = amount;
                          // await BarangService().addBarangKeranjang(widget.groceryItem.id_barang!, newQty.toDouble()).then((value) {
                          // // await cartProvider.addCart(widget.groceryItem.id!, newQty, context).then((value) {
                          //   setState(() {
                          //     isLoadSaveToCart = false;
                          //   });
                          // });
                          Utils.showSuccessSnackBar(context: context, text: "${widget.groceryItem.nama_barang} x${newQty} berhasil ditambahkan!", showLoad: false);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } catch (e) {
                          print(e);
                        }
                      },
                      isEnabled: true,
                      isLoad: isLoadSaveItemDaftar
                    )
                  ],
                )
              ),

              SizedBox(height: 20), // More controlled spacing
            ],
          ),
        ),
      );

      }); 
  }

  Widget getAddDaftar(BuildContext context, Function onPressed, String label, {required isEnabled, required  bool isLoad}) {
    return Expanded(
      flex: 2,
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: AppButtonColor(
          border: BorderSide(color: AppColors.secondaryColor, width: 1),
          isEnabled: isEnabled,
          onPressed: onPressed, // Pastikan fungsi yang benar digunakan
          content: Column(
            children: [
              isLoad
              ? Center(
                  child: Container(
                    width: AppConfig.appSize(context, .02),
                    height: AppConfig.appSize(context, .02),
                    child: CircularProgressIndicator(
                      color: AppColors.darkSecondaryColor,
                    )
                  ),
                )
              : SvgPicture.asset(
                "assets/icons/file_add_icon.svg",
                width: AppConfig.appSize(context, .02),
                height: AppConfig.appSize(context, .02),
                color: AppColors.secondaryColor,
              ),
            ],
          ),
          color: Colors.white,
        ),
      ),
    );
  }
  Widget getAddCart(BuildContext context, Function onPressed, {required isEnabled, required isLoad}) {
    return Expanded(
      flex: 8,
      child: Container(
        // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: AppButtonColor(
          border: null,
          isEnabled: isEnabled,
          onPressed: onPressed, // Pastikan fungsi yang benar digunakan
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
                'Tambah',
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

  Widget getImageHeaderWidget() {
    return Container(
      height: AppConfig.appSize(context, .28),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Color(0xFFF2F3F2),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
        // gradient: new LinearGradient(
        //     colors: [
        //       const Color(0xFF3366FF).withOpacity(0.1),
        //       const Color(0xFF3366FF).withOpacity(0.09),
        //     ],
        //     begin: const FractionalOffset(0.0, 0.0),
        //     end: const FractionalOffset(0.0, 1.0),
        //     stops: [0.0, 1.0],
        //     tileMode: TileMode.clamp),
      ),
      child: Hero(
        tag: "GroceryItem:" +
            widget.groceryItem.nama_barang +
            "-" +
            (widget.heroSuffix ?? ""),
        // child: Image(
        //   image: NetworkImage(
        //     "${AppConfig.api_ip}/barang/image/${widget.groceryItem.foto}",
        //   ),
        // ),
        child: 
        Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: AppConfig.appSize(context, .03),),
                    CachedNetworkImage(
                      height: AppConfig.appSize(context, .2),
                      width: AppConfig.appSize(context, .2),
                      imageUrl: widget.groceryItem.gambar == '' ? "${AppConfig.api_ip}/storage/not-found.png" : "${AppConfig.api_ip}/storage/${widget.groceryItem.gambar}",
                      progressIndicatorBuilder: (context, url, progress) {
                        return Skeletonizer(
                        effect: ShimmerEffect(
                          baseColor: Colors.grey.shade200,
                          highlightColor: Colors.white,
                          duration: Duration(milliseconds: 1200),
                        ),
                          child: Skeleton.leaf(
                            child: Container(width: double.maxFinite, height: AppConfig.appSize(context, .2),)
                          )
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: AppConfig.appSize(context, .01),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.only(
                        // right: AppConfig.appSize(context, .01), 
                        // left: AppConfig.appSize(context, .01), 
                        bottom: AppConfig.appSize(context, .01),
                        top: AppConfig.appSize(context, .01)
                      ),
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          FaIcon(FontAwesomeIcons.arrowLeft, size: AppConfig.appSize(context, .02),),
                        ],
                      )
                    )
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }

  Widget getProductDataRowWidget(String label, {Widget? customWidget}) {
    return Container(
      margin: EdgeInsets.only(
        top: 20,
        bottom: 20,
      ),
      child: Row(
        children: [
          AppText(text: label, fontWeight: FontWeight.w600, fontSize: 16),
          Spacer(),
          if (customWidget != null) ...[
            customWidget,
            SizedBox(
              width: 20,
            )
          ],
          Icon(
            Icons.arrow_forward_ios,
            size: 20,
          )
        ],
      ),
    );
  }

  Widget nutritionWidget() {
    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0xffEBEBEB),
        borderRadius: BorderRadius.circular(5),
      ),
      child: AppText(
        text: "100gm",
        fontWeight: FontWeight.w600,
        fontSize: 12,
        color: Color(0xff7C7C7C),
      ),
    );
  }

  Widget ratingWidget() {
    Widget starIcon() {
      return Icon(
        Icons.star,
        color: Color(0xffF3603F),
        size: 20,
      );
    }

    return Row(
      children: [
        starIcon(),
        starIcon(),
        starIcon(),
        starIcon(),
        starIcon(),
      ],
    );
  }

  double getTotalPromoPrice() {
    return amount * widget.groceryItem.harga;
  }

  double getTotalPrice() {
    return amount * widget.groceryItem.harga;
  }

  void onDenahClick(String imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true, // Dialog tidak akan tertutup saat di luar dialog di-tap
      builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // Kurangi radius
        ),
        content: 
        Column(
          mainAxisSize: MainAxisSize.min, // Membuat kolom mengikuti ukuran konten
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(
                image: NetworkImage(
                  imageUrl,
                ),
                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                  return Container(); // If image fails to load
                },
              ),
          ],
        ),
      );
    },
    );
  }

  Future<void> showBelumDaftar(context, {required Function(String) onPressed}) async {
    TextEditingController _budgetApproveController = TextEditingController();

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
            height: AppConfig.appSize(context, .22),
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(
              vertical: AppConfig.appSize(context, .028),
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
                        text: AppLocalizations.of(context)!.activity_budget_change_title,
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
                    child: TextFormField(
                      textInputAction: TextInputAction.done,
                      controller: _budgetApproveController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CurrencyInputFormatter(),
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        hintText: AppLocalizations.of(context)!.activity_budget_change_hint,
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
                    child: Container(
                      // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                      child: AppButtonColor(
                        border: null,
                        isEnabled: true,
                        onPressed: () async {
                          try {
                            String budget = _budgetApproveController.text;
                            await onPressed(budget);
                          } catch (e) {
                            throw(e);
                          }
                        },
                        content: Column(
                          children: [
                            Text(
                              AppLocalizations.of(context)!.activity_budget_change_button,
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
}
