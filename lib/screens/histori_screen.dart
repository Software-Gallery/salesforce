import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/helpers/column_with_seprator.dart';
import 'package:salesforce/models/rute_item.dart';
import 'package:salesforce/models/trn_sales_order_header.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/screens/view_kunjungan.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class HistoriScreen extends StatefulWidget {
  const HistoriScreen({super.key});

  @override
  State<HistoriScreen> createState() => _HistoriScreenState();
}

class _HistoriScreenState extends State<HistoriScreen> {
  bool isTrnLoad = true;
  String tglaktif = '2025-12-31';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final prefstglaktif = await prefs.getString('tglaktif') ?? '';
        setState(() {
          tglaktif = prefstglaktif;
          startDate = DateFormat('yyyy-MM-dd').parse(tglaktif);
          startDate = DateFormat('yyyy-MM-dd').parse(tglaktif);
          // startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
          // endDate = DateTime.now();
        });
        final ruteProvider = Provider.of<RuteProvider>(context, listen: false);
        // DateFormat('yyyy-MM-dd').format(endDate!)
        await ruteProvider.populateHistoriFromApi(tglaktif, tglaktif).then((value) async {
          await Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
              isTrnLoad = false;
            });
          });
        });     
        // final trnHeaderProvider = Provider.of<TrmSalesOrderHeaderProvider>(context, listen: false);
        // await trnHeaderProvider.populateFromApi().then((value) async {
        //   await Future.delayed(Duration(milliseconds: 500)).then((value) {
        //     setState(() {
        //       isTrnLoad = false; 
        //     });
        //   });
        // });     
      } catch (e) {
        print(e.toString());
      }
    });
  }

  void setDateRange() {
    setState(() {
      startDate = DateTime.now().subtract(Duration(days: 3));
      endDate = DateTime.now();
    });
  }

  Future<void> loadPref() async {
    final prefs = await SharedPreferences.getInstance();
    final prefstglaktif = await prefs.getString('tglaktif') ?? '';
    setState(() {
      tglaktif = prefstglaktif;
    });
  }  

  DateTime? startDate;
  DateTime? endDate;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<RuteProvider>(
      builder: (context, ruteProvider, child) {

        Future<void> _fetchData() async {
          if (startDate != null && endDate != null) {
            await ruteProvider.populateHistoriFromApi(
              DateFormat('yyyy-MM-dd').format(startDate!),
              DateFormat('yyyy-MM-dd').format(endDate!),
            ).then((value) async {
              await Future.delayed(Duration(milliseconds: 500)).then((value) {
                setState(() {
                  isTrnLoad = false;
                });
              });
            });
          }
        }

void _selectDateRange(BuildContext context) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // Menambahkan border radius
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppConfig.appSize(context, .02),),
            SfDateRangePicker(
              backgroundColor: Colors.white,
              // startRangeSelectionColor: AppColors.primaryColor,
              // endRangeSelectionColor: AppColors.primaryColor,
              // selectionColor: AppColors.primaryColor,
              headerStyle: DateRangePickerHeaderStyle(
                textAlign: TextAlign.center,
                backgroundColor: Colors.white,
              ),
              showNavigationArrow: false,
              // rangeSelectionColor: const Color.fromARGB(102, 255, 102, 0),
              view: DateRangePickerView.month,
              selectionMode: DateRangePickerSelectionMode.range,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  // Mengambil tanggal mulai dan tanggal akhir dari rentang yang dipilih
                  startDate = args.value.startDate;
                  endDate = args.value.endDate;
                });
              },
              onSubmit: (Object? value) {
                // Ketika rentang tanggal telah dipilih, simpan hasilnya
                if (value is PickerDateRange) {
                  setState(() {
                    startDate = value.startDate;
                    endDate = value.endDate;
                  });
                }
                Navigator.of(context).pop();
              },
              onCancel: () {
                Navigator.of(context).pop();
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      if (startDate != null && endDate != null) {
                        _fetchData();
                      } else {
                        Utils.showActionSnackBar(
                          context: context,
                          text: 'Pilih rentang tanggal terlebih dahulu',
                          showLoad: false,
                        );
                      }
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Oke',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}



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
                SizedBox(height: AppConfig.appSize(context, .02),),
                padded(
                  AppButton(label: startDate == null || endDate == null ? 'Pilih Tanggal' : "${DateFormat('dd-MM-yyyy').format(startDate!)} - ${DateFormat('dd-MM-yyyy').format(endDate!)}", onPressed: () {_selectDateRange(context);}, color: AppColors.accentColor,)               
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
                        widgets: ruteList.map((e) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                            ),
                            width: double.maxFinite,
                            child: Skeleton.leaf(
                                child: visitCard(e,)
                              )
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
                  ruteProvider.historiLists.length <= 0
                  ? Center(
                    child: Column(
                      children: [
                        SizedBox(
                          height: AppConfig.appSize(context, .1),
                        ),
                        Text(
                          'Belum ada kunjungan',
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
                      widgets: ruteProvider.historiLists.map((e) {
                        return  Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          width: double.maxFinite,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                    ViewKunjungan(
                                      item: e,
                                    ),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
                              );
                            },
                            child: visitCard(e),
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

  Widget padded(Widget widget) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)),
      child: widget,
    );
  }    

  Widget visitCard(RuteItem e) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 10,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   "#${e.kode_sales_order}",
                      //   style: const TextStyle(
                      //     fontSize: 12,
                      //     fontWeight: FontWeight.bold,
                      //     color: AppColors.darkGrey
                      //   ),
                      // ),
                      Row(
                        children: [
                          Text(
                            "#${e.kode_sales_order}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGrey
                            ),
                          ),
                          SizedBox(width: AppConfig.appSize(context, .006),),
                          e.status == ''
                          ? Text('')
                          : Container(
                            padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .008), vertical: AppConfig.appSize(context, .002)),
                            decoration: BoxDecoration(
                              color: e.status == 'DRAFT' ? AppColors.lightAccentColor : e.status == 'POSTED' ? Colors.amber : AppColors.lightSecondaryColor,
                              borderRadius: BorderRadius.circular(AppConfig.appSize(context, .02))
                            ),
                            child: Text(
                              e.status,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                              ),
                            ),                      
                          )  
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        e.nama_customer,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
            
                    ],
                  ),
                ),
                Container(
                  width: AppConfig.appSize(context, .1),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('d MMM y', 'id').format(DateFormat('yyyy-MM-dd').parse(e.tgl)),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),                             
                      Text(
                        e.jam_masuk,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        e.jam_keluar,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 5,),
            Row(
              children: [         
                  Text(
                    'Total SKU: ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),                
                  Text(
                    '${e.totalSKU}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),                
                  Spacer(),
                  Text(
                    'Total Value: ',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),                
                  Text(
                    '${AppConfig.formatNumber(e.totalValue)}',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  ),                
              ],
            )
          ],
        ),
      ),
    );
  }
}