import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChartBarangWidget extends StatefulWidget {
  ChartBarangWidget({Key? key, required this.item}) : super(key: key);
  final BarangItem item;

  @override
  _ChartBarangWidgetState createState() => _ChartBarangWidgetState();
}

class _ChartBarangWidgetState extends State<ChartBarangWidget> {
  final double height = 110;

  final Color borderColor = Color(0xffE2E2E2);

  final double borderRadius = 18;

  int amount = 1;

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
    return Container(
      height: height,
      margin: EdgeInsets.only(
        top: 10,
      ),
      padding:  EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.darkGrey.withOpacity(.2),))
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            imageWidget(context),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .3,
                  child: Text(
                    singkat(widget.item.nama_barang),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    maxLines: null,       
                  ),
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .3,
                  child: Row(
                    children: [
                      AppText(
                        text: AppConfig.formatNumber(getPrice()),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        textAlign: TextAlign.right,
                      ),

                      Icon(Icons.keyboard_arrow_right, size: 30,)
                    ],
                  )
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget imageWidget(BuildContext context) {
    return Container(
      width: AppConfig.appSize(context, .08),
      // child: 
      // Image(
      //   image: NetworkImage(
      //     "${AppConfig.api_ip}/barang/image/${widget.item.foto}", // Use promo.id here
      //   ),
      // ),
      child: CachedNetworkImage(
        // imageUrl: "${AppConfig.api_ip}/barang/image/${widget.item.foto}",
        imageUrl: widget.item.gambar == '' ? "${AppConfig.api_ip}/storage/not-found.png" : "${AppConfig.api_ip}/storage/${widget.item.gambar}",
        progressIndicatorBuilder: (context, url, progress) {
          return Skeletonizer(
effect: ShimmerEffect(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.white,
            duration: Duration(milliseconds: 1200),
          ),
            child: Skeleton.leaf(
              child: Container(width: double.maxFinite, height: AppConfig.appSize(context, .07),)
            )
          );
        },
      ),
    );
  }

  double getPrice() {
    return widget.item.harga * amount;
  }
}
