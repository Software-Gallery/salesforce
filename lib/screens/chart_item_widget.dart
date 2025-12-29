// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:salesforce/common_widgets/Utils.dart';
// import 'package:salesforce/common_widgets/app_text.dart';
// import 'package:salesforce/config.dart';
// import 'package:salesforce/models/barang_item.dart';
// import 'package:salesforce/provider/CartProvider.dart';
// import 'package:salesforce/services/BarangService.dart';
// import 'package:salesforce/styles/colors.dart';
// import 'package:salesforce/widgets/item_counter_widget.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:skeletonizer/skeletonizer.dart';

// class ChartItemWidget extends StatefulWidget {
//   const ChartItemWidget({
//     Key? key,
//     required this.item,
//     required this.qty,
//     required this.onCloseTap,
//     required this.isItemLast,
//   }) : super(key: key);

//   final Function(String idBarang) onCloseTap;
//   final BarangItem item;
//   final int qty;
//   final bool isItemLast;

//   @override
//   _ChartItemWidgetState createState() => _ChartItemWidgetState();
// }

// class _ChartItemWidgetState extends State<ChartItemWidget> {
//   final Color borderColor = Color(0xffE2E2E2);
//   final double borderRadius = 18;
//   late int amount;

//   String singkat(String nama) {
//     List<String> words = nama.split(' ');

//     if (words.length < 3) {
//       return nama;
//     }

//     String firstTwoWords = words.sublist(0, 2).join(' ');
//     String lastWord =
//         "${words[words.length - 2] != words[1] ? words[words.length - 2] + ' ' : ''}${words.last}";

//     return '$firstTwoWords $lastWord';
//   }

//   @override
//   void initState() {
//     super.initState();
//     amount = widget.qty; // Initialize amount with widget.qty
//   }

//   @override
//   Widget build(BuildContext context) {

//     return Consumer<CartProvider>(
//       builder: (context, cartProvider, child) {

//       Future<void> updateQty() async {
//         try {
//           // BarangService().updateCartQty(widget.item.kode_barang, amount);
//           cartProvider.updateQty(widget.item.kode_barang, amount);
//         } catch (e) {
//           Utils.showActionSnackBar(context: context,showLoad: true,text: e.toString());
//         }
//       }

//       double getPrice() {
//         return widget.item.harga * amount;
//       }

//       return Container(
//         padding: EdgeInsets.only(
//           bottom: AppConfig.appSize(context, .02),
//           top: AppConfig.appSize(context, .01),
//         ),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: 
//               widget.isItemLast ? Colors.white : AppColors.darkGrey.withOpacity(.2),
//               width: 1.0,
//             ),
//           ),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             imageWidget(context),
//             SizedBox(width: AppConfig.appSize(context, .004)),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded( // Menggunakan Expanded agar teks nama mengisi ruang yang tersedia tanpa mendorong ikon
//                         child: Text(
//                           singkat(widget.item.nama_barang),
//                           style: TextStyle(
//                             fontSize: AppConfig.appSize(context, .013),
//                             fontWeight: FontWeight.bold,
//                           ),
//                           softWrap: true,
//                           overflow: TextOverflow.clip, // Biarkan teks pindah ke baris berikutnya jika terlalu panjang
//                           maxLines: null, // Agar bisa memiliki banyak baris
//                         ),
//                       ),
//                       SizedBox(width: AppConfig.appSize(context, .01)), // Spasi antara teks dan ikon
//                       GestureDetector(
//                         onTap: () => widget.onCloseTap(widget.item.kode_barang),
//                         child: Icon(
//                           Icons.close,
//                           color: AppColors.darkGrey,
//                           size: AppConfig.appSize(context, .02),
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: AppConfig.appSize(context, .01)),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       ItemCounterWidget(
//                         onAmountChanged: (newAmount) async {
//                           setState(() {
//                             amount = newAmount;
//                           });
//                           await updateQty();
//                         },
//                         qty: widget.qty,
//                       ),
//                       Expanded(child: Container()), // Memberikan jarak antara counter dan harga
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           AppText(
//                             text: AppConfig.formatNumber(getPrice()),
//                             fontSize: AppConfig.appSize(context, .014),
//                             fontWeight: FontWeight.bold,
//                             textAlign: TextAlign.right,
//                           ),
//                           // if (widget.item.diskon != 0)
//                           Row(
//                             children: [
//                               // Container(
//                               //   margin: EdgeInsets.only(right: 5),
//                               //   padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
//                               //   decoration: BoxDecoration(
//                               //     borderRadius: BorderRadius.circular(6),
//                               //     color: AppColors.accentColor,
//                               //   ),
//                               //   child: Center(
//                               //     child: Text(
//                               //       "${widget.item.diskon}%", 
//                               //       style: TextStyle(
//                               //         fontSize: AppConfig.appSize(context, .01), 
//                               //         color: Colors.white, 
//                               //         fontWeight: FontWeight.w900
//                               //       ),
//                               //     ),
//                               //   ),
//                               // ),
//                               Text(
//                                 AppConfig.formatNumber(getPrice()),
//                                 style: TextStyle(
//                                   color: AppColors.darkGrey,
//                                   fontSize: AppConfig.appSize(context, .012),
//                                   decoration: TextDecoration.lineThrough,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
                      
//                     ],
//                   ),
//                 ],
//               ),
//             )


//           ],
//         ),
//       );
//       });
//   }

//   Widget imageWidget(BuildContext context) {
//     return Container(
//       width: AppConfig.appSize(context, .06),
//       // child: Image(
//       //   image: NetworkImage(
//       //     "${AppConfig.api_ip}/barang/image/${widget.item.foto}",
//       //   ),
//       // ),
//       child: CachedNetworkImage(
//         imageUrl: "${AppConfig.api_ip}/barang/image/${widget.item.gambar}",
//         progressIndicatorBuilder: (context, url, progress) {
//           return Skeletonizer(
//           effect: ShimmerEffect(
//             baseColor: Colors.grey.shade200,
//             highlightColor: Colors.white,
//             duration: Duration(milliseconds: 1200),
//           ),
//             child: Skeleton.leaf(
//               child: Card(child: Container(width: AppConfig.appSize(context, .05), height: AppConfig.appSize(context, .05),))
//             )
//           );
//         },
//       ),      
//     );
//   }

// }
