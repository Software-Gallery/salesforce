import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/helpers/column_with_seprator.dart';
import 'package:salesforce/models/trn_sales_order_header.dart';
import 'package:salesforce/provider/TrnSalesOrderHeaderProvider.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HistoriScreen extends StatefulWidget {
  const HistoriScreen({super.key});

  @override
  State<HistoriScreen> createState() => _HistoriScreenState();
}

class _HistoriScreenState extends State<HistoriScreen> {
  bool isTrnLoad = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
  @override
  Widget build(BuildContext context) {
    return Consumer<TrmSalesOrderHeaderProvider>(
      builder: (context, trmHeaderProvider, child) {
        return Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white), 
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            title: Container(
              child: AppText(
                text: 'History',
                fontWeight: FontWeight.bold,
                fontSize: AppConfig.appSize(context, .016),
                color: Colors.white,
              ),
            ),
          ),          
          body: SingleChildScrollView(
            child: Column(
              children: [
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
                        widgets: listSalesOrder.map((e) {
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
                          'No recent sales order yet.',
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
                            onTap: () {}, 
                            child: visitCard(e.id_customer.toString(), e.tgl_ref),
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
                ),
                SizedBox(height: AppConfig.appSize(context, .02),),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget visitCard(String companyName, DateTime visitDate) {
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
          ],
        ),
      ),
    );
  }

}