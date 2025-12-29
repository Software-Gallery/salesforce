import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/chart_barang_widget.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/helpers/column_with_seprator.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/screens/barang_details_screen.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  Widget barangGrid = Center(child: Text('Belum Ada Promo'),);
  bool bestDealSlideLoad = true;

  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final barangProvider = Provider.of<BarangProvider>(context, listen: false);
        barangProvider.produkCartPopulateFromApi().then((value) {
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
  Widget build(BuildContext context) {
    return Consumer<BarangProvider>(
      builder: (context, barangProvider, child) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white), 
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            title: Container(
              child: AppText(
                text: 'Keranjang',
                fontWeight: FontWeight.bold,
                fontSize: AppConfig.appSize(context, .016),
                color: Colors.white,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: 
              // bestDealSlideLoad
              //         ? CircularProgressIndicator()
              //         : barangGrid
              SkeletonLoader(
                isLoading: bestDealSlideLoad,
                skeleton: Skeletonizer(
                  effect: ShimmerEffect(
                    baseColor: Colors.grey.shade200,
                    highlightColor: Colors.white,
                    duration: Duration(milliseconds: 1200),
                  ),
                  child: Column(
                    children: getChildrenWithSeperator(
                      addToLastChild: false,
                      widgets: barangList.map((e) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          width: double.maxFinite,
                          child: Skeleton.leaf(
                            child: Card(
                              child: ChartBarangWidget(
                                item: e,
                              ),
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
                barangProvider.itemCartLists.length <= 0
                ? Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: AppConfig.appSize(context, .1),
                      ),
                      Text(
                        'No items added yet.',
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
                    widgets: barangProvider.itemCartLists.map((e) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        width: double.maxFinite,
                        child: GestureDetector(
                          onTap: () {
                            onItemClicked(context, e);
                          }, 
                          child: ChartBarangWidget(
                            item: e,
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
                )
              )
            ),
          ),
        );
      }
    );
  }

  void onItemClicked(BuildContext context, BarangItem barangItem) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BarangDetailsScreen(
            barangItem,
            false,
            heroSuffix: "promo_screen",
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

}