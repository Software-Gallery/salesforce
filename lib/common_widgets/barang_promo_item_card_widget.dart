import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BarangPromoItemCardWidget extends StatelessWidget {
  BarangPromoItemCardWidget({Key? key, required this.item, this.heroSuffix})
      : super(key: key);
  final BarangItem item;
  final String? heroSuffix;

  final Color borderColor = Color(0xffE2E2E2);
  final double borderRadius = 10;

  String singkat(String nama) {
    // Memisahkan kalimat menjadi kata-kata
    List<String> words = nama.split(' ');

    // Mengecek jumlah kata
    if (words.length < 3) {
      return nama;
    }

    // Mengambil 2 kata depan dan 1 kata belakang
    String firstTwoWords = words.sublist(0, 2).join(' ');
    String lastWord = "${words[words.length -2] != words[1] ? words[words.length -2] + ' ' : ''}${words.last}";

    return '$firstTwoWords $lastWord';
  }

  @override
  Widget build(BuildContext context) {
    final double width = AppConfig.appSize(context, .16);
    final double height = AppConfig.appSize(context, .2);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // border: Border.all(
        //   color: borderColor,
        // ),
        borderRadius: BorderRadius.circular(
          borderRadius,
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0xFF000000).withOpacity(.05), blurRadius:10)
        ]
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Hero(
                  tag: "BarangItem:" + item.nama_barang + "-" + (heroSuffix ?? ""),
                  child: imageWidget(context),
                ),
              ),
            ),
            SizedBox(
              height: AppConfig.appSize(context, .012),
            ),
            AppText(
              text: item.kode_barang,
              fontSize: AppConfig.appSize(context, .01),
              fontWeight: FontWeight.bold,
              color: AppColors.accentColor,
            ),
            AppText(
              text: singkat(item.nama_barang),
              fontSize: AppConfig.appSize(context, .012),
              fontWeight: FontWeight.bold,
            ),
            // AppText(
            //   text: item.deskripsi,
            //   fontSize: 14,
            //   fontWeight: FontWeight.w600,
            //   color: Color(0xFF7C7C7C),
            // ),
            SizedBox(
              height: AppConfig.appSize(context, .01),
            ),
            AppText(
              text: AppConfig.formatNumber(item.harga),
              fontSize: AppConfig.appSize(context, .012),
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      ),
    );
  }

  Widget imageWidget(BuildContext context) {
    return Container(
      height: AppConfig.appSize(context, .125),
      // child: Image(
      //   image: NetworkImage(
      //     "${AppConfig.api_ip}/barang/image/${item.foto}", // Use promo.id here
      //   ),
      // ),
      child: CachedNetworkImage(
        imageUrl: item.gambar == '' ? "${AppConfig.api_ip}/storage/not-found.png" : "${AppConfig.api_ip}/storage/${item.gambar}",
        progressIndicatorBuilder: (context, url, progress) {
          return Skeletonizer(
            effect: ShimmerEffect(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.white,
            duration: Duration(milliseconds: 1200),
          ),
            child: Skeleton.leaf(
              child: Card(child: Container(width: double.maxFinite, height: AppConfig.appSize(context, .125),))
            )
          );
        },
      ),
    );
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
}
