import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/common_widgets/skeleton_loader.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/helpers/column_with_seprator.dart';
import 'package:salesforce/models/customer_item.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/screens/histori_screen.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  DateTime? startDate;
  DateTime? endDate;
  String tglaktif = '';
  int _selectedTab = 0; 
  int iduser = -1;
  List<CustomerItem> _customers = [];
  List<Map<String,dynamic>> _listCustomers = [];
  CustomerItem _selectedCustomer = CustomerItem(id: -999, nama: '', alamat: '');   
  Timer? _debounce;  
  late Future<void> Function() _onPopulate;
  late RuteProvider ruteProvider;
  bool isTrnLoad = false;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadTglAktif();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        ruteProvider = Provider.of<RuteProvider>(context, listen: false);

        _onPopulate = () async {
          await ruteProvider.populateHistoriFromApi(
            DateFormat('yyyy-MM-dd').format(startDate!), DateFormat('yyyy-MM-dd').format(endDate!),
            _selectedCustomer.id,
          );
        };

        setState(() {});
        final SharedPreferences prefs = await SharedPreferences.getInstance();        
        setState(() {
          iduser = prefs.getInt('loginidkaryawan') ?? 0;              
        });
        setState(() {
          isTrnLoad = true;
        });
        await _fetchcustomer(iduser,'');
        await _onPopulate().then((value) async {
          await Future.delayed(Duration(milliseconds: 500)).then((value) {
            setState(() {
              isTrnLoad = false;
            });
          });
        }); ;
      }
      catch(e) {
      }
    });      
  }

  Future<void> _loadTglAktif() async {
    final prefs = await SharedPreferences.getInstance();
    final prefstglaktif = await prefs.getString('tglaktif') ?? '';
    setState(() {
      tglaktif = prefstglaktif;
      startDate = DateFormat('yyyy-MM-dd').parse(tglaktif);
      endDate = DateFormat('yyyy-MM-dd').parse(tglaktif);
      // startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
      // endDate = DateTime.now();
    });
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
                  // setState(() {
                  //   startDate = args.value.startDate;
                  //   endDate = args.value.endDate;
                  // });
                },
                showActionButtons: true,
                onSubmit: (Object? value) {
                  if (value is PickerDateRange) {
                    if (value.startDate != null && value.endDate != null) {
                      // _fetchData();
                    } else {
                      Utils.showActionSnackBar(
                        context: context,
                        text: 'Pilih rentang tanggal terlebih dahulu',
                        showLoad: false,
                      );
                      return;
                    }                    
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
                   
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) async {
      setState(() {
        isTrnLoad = true;
      });
      await _onPopulate().then((value) async {
        await Future.delayed(Duration(milliseconds: 500)).then((value) {
          setState(() {
            isTrnLoad = false;
          });
        });
      });
    });
  }

  Future<void> _fetchcustomer(int id, String nama) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      nama = Uri.encodeComponent(nama ?? '');
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/customer?id=$id'
        : url =  '$IPConnectShared:$IPPortShared/api/customer?id=$id';
      if (!(nama == '')) {
        url += '&nama=$nama';
      }  
      print(url);
      final response = await Dio().get(url);
      if (response.statusCode != 200) {
        return;
      }

      final responseData = response.data as Map<String, dynamic>;
      final List<dynamic> data = responseData['data'];

      if (data.isEmpty) {
        return;
      }
      // List<dynamic> result = responseData['data']['data'];
      List<CustomerItem> tempCustomer = [];
      for (var item in data) {
        tempCustomer.add(CustomerItem.fromJson(item));
      }
      setState(() {
        _listCustomers = data
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
        _customers = tempCustomer;
      });

      return;
    } catch (e) {
      print(e);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RuteProvider>(
      builder: (context, ruteProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          // appBar: AppBar(
          //   backgroundColor: Colors.white,
          //   elevation: 1,
          //   leading: IconButton(
          //     icon: const Icon(Icons.menu, color: AppColors.primaryColor, size: 30),
          //     onPressed: () {},
          //   ),
          //   title: Column(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: const [
          //       Text(
          //         'My Performance',
          //         style: TextStyle(
          //           color: Colors.black87,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 18,
          //         ),
          //       ),
          //       Text(
          //         'Imron Al Amin - 121',
          //         style: TextStyle(
          //           color: Colors.grey,
          //           fontSize: 14,
          //           fontWeight: FontWeight.normal,
          //         ),
          //       ),
          //     ],
          //   ),
          //   centerTitle: true,
          //   actions: [
          //     IconButton(
          //       icon: const Icon(Icons.more_vert, color: AppColors.primaryColor),
          //       onPressed: () {},
          //     ),
          //   ],
          // ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [       
                  // Top Tabs
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Autocomplete<CustomerItem>(
                              displayStringForOption: (CustomerItem c) => c.nama,

                              optionsBuilder: (TextEditingValue textEditingValue) async {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<CustomerItem>.empty();
                                }

                                _debounce?.cancel();
                                final completer = Completer<Iterable<CustomerItem>>();

                                _debounce = Timer(const Duration(milliseconds: 500), () async {
                                  await _fetchcustomer(iduser, textEditingValue.text);

                                  final result = _customers.where((c) =>
                                      c.nama.toLowerCase().contains(
                                            textEditingValue.text.toLowerCase(),
                                          ));

                                  completer.complete(result);
                                });

                                return completer.future;
                              },

                              onSelected: (CustomerItem selection) async {
                                try {
                                  setState(() {
                                    _selectedCustomer = selection;
                                    isTrnLoad = true;
                                  });
                                  await _onPopulate().then((value) async {
                                  await Future.delayed(Duration(milliseconds: 500)).then((value) {
                                    setState(() {
                                      isTrnLoad = false;
                                    });
                                  });
                                }); ;
                                } catch (e) {
                                  print(e);
                                }
                              },

                              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                                return TextFormField(
                                  controller: controller,
                                  focusNode: focusNode,
                                  onTapOutside: (_) => focusNode.unfocus(),
                                  onFieldSubmitted: (value) => focusNode.unfocus(),
                                  decoration: InputDecoration(
                                    hintText: 'All Customer',
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder( borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300), ), enabledBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300), ), focusedBorder: OutlineInputBorder( borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryColor), ),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.arrow_drop_down,
                                          color: AppColors.primaryColor),
                                      onPressed: () {
                                        focusNode.hasFocus
                                            ? focusNode.unfocus()
                                            : focusNode.requestFocus();
                                      },
                                    ),
                                  ),

                                  onChanged: (value) async {
                                    if (value.isEmpty) {
                                      setState(() => _selectedCustomer = CustomerItem(id: -999, nama: '', alamat: ''));
                                      setState(() {
                                        isTrnLoad = true;
                                      });
                                      await _onPopulate().then((value) async {
                                        await Future.delayed(Duration(milliseconds: 500)).then((value) {
                                          setState(() {
                                            isTrnLoad = false;
                                          });
                                        });
                                      });
                                    }
                                  },
                                );
                              },

                              optionsViewBuilder:
                                  (context, AutocompleteOnSelected<CustomerItem> onSelected, options) {
                                return Align(
                                  alignment: Alignment.topLeft,
                                  child: Material(
                                    elevation: 4,
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        shrinkWrap: true,
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          final customer = options.elementAt(index);
                                          return InkWell(
                                            onTap: () => onSelected(customer),
                                            child: Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(customer.nama,
                                                      style:
                                                          const TextStyle(fontWeight: FontWeight.w600)),
                                                  Text('${customer.alamat}',
                                                      style: const TextStyle(
                                                          fontSize: 13, color: Colors.black87)),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(height: AppConfig.appSize(context, .01),),   
                        GestureDetector(
                          onTap: () => _selectDateRange(context),
                          // onTap: () => print(_selectedCustomer),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: AppConfig.appSize(context, 0.01),
                              horizontal: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    startDate == null || endDate == null
                                        ? 'Pilih Tanggal'
                                        : "${DateFormat('dd MMMM yyyy', 'id_ID').format(startDate!)}"
                                          "${startDate == endDate ? '' : ' - ${DateFormat('dd MMMM yyyy', 'id_ID').format(endDate!)}'}",
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: startDate == endDate ? AppConfig.appSize(context, .013) : AppConfig.appSize(context, .012)),
                                  ),
                                ),
                                Icon(FontAwesomeIcons.calendar, color: AppColors.primaryColor,),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppConfig.appSize(context, .01),),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    isTrnLoad = true;
                                  });
                                  setState(() => _selectedTab = 0);
                                  await _onPopulate().then((value) async {
                                    await Future.delayed(Duration(milliseconds: 500)).then((value) {
                                      setState(() {
                                        isTrnLoad = false;
                                      });
                                    });
                                  }); ;
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 0
                                        ? AppColors.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Performa',
                                    style: TextStyle(
                                      color: _selectedTab == 0
                                          ? Colors.white
                                          : AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 5,),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedTab = 1),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _selectedTab == 1
                                        ? AppColors.primaryColor
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Target Pencapaian',
                                    style: TextStyle(
                                      color: _selectedTab == 1
                                          ? Colors.white
                                          : AppColors.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),        
                  // Content Switcher
                  // if (_selectedTab == 0) _buildPerformaContent() else _buildTargetContent(),
                  if (_selectedTab == 0) _buildTargetContent(ruteProvider) else HistoriScreen(startDate: startDate!, endDate: endDate!, customer: _selectedCustomer!, onPopulate: _onPopulate!),
                  
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildTargetContent(RuteProvider ruteProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        SkeletonLoader(
          isLoading: isTrnLoad,
          skeleton: Skeletonizer(
            effect: ShimmerEffect(
              baseColor: Colors.grey.shade200,
              highlightColor: Colors.white,
              duration: Duration(milliseconds: 1200),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Performa Penjualan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildBentoStat(
                          title: 'Penjualan',
                          value: '2000000000000000000000',
                          icon: Icons.payments_rounded,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),  
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildBentoStat(
                          title: 'Active Outlet',
                          value: '20000',
                          icon: Icons.store_rounded,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(width: 12,),
                      Expanded(
                        flex: 2,
                        child: _buildBentoStat(
                          title: 'Avg. SKU',
                          value: '20000',
                          icon: Icons.inventory_2_rounded,
                          color: Colors.orange,
                        ),
                      ),          
                    ],
                  ),
                  // const SizedBox(height: 12),
                  // Row(
                  //   children: [

                  //   ],
                  // ),
                  
                ],
              ),
            ),
          ), 
          child: 
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performa Penjualan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildBentoStat(
                        title: 'Penjualan',
                        value: AppConfig.formatNumber(ruteProvider.totalValueNota.toDouble()),
                        icon: Icons.payments_rounded,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),  
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildBentoStat(
                        title: 'Active Outlet',
                        value: ruteProvider.distinctCustomerCount.toString(),
                        icon: Icons.store_rounded,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(width: 12,),
                    Expanded(
                      flex: 2,
                      child: _buildBentoStat(
                        title: 'Avg. SKU',
                        value: ruteProvider.averageSKU.toString(),
                        icon: Icons.inventory_2_rounded,
                        color: Colors.orange,
                      ),
                    ),          
                  ],
                ),
                // const SizedBox(height: 12),
                // Row(
                //   children: [

                //   ],
                // ),
                
              ],
            ),
          ),
        ),    
      ],
    );    
  }

  Widget _buildBentoStat({
    required String title,
    required String value,
    IconData? icon,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // if (icon != null)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color?.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                softWrap: true,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.bold
                ),
              ),              
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )

        ],
      ),
    );
  }
  
  Widget padded(Widget widget) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppConfig.appSize(context, .02)),
      child: widget,
    );
  }    

  // Widget _buildFilterChip(String label) {
  //   final isSelected = _selectedFilter == label;
  //   return GestureDetector(
  //     onTap: () {
  //       setState(() {
  //         _selectedFilter = label;
  //       });
  //     },
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: isSelected ? AppColors.accentColor : Colors.white,
  //         borderRadius: BorderRadius.circular(8),
  //         border: Border.all(
  //           color: AppColors.accentColor,
  //           width: 1.5,
  //         ),
  //       ),
  //       child: Text(
  //         label,
  //         style: TextStyle(
  //           color: isSelected ? Colors.white : AppColors.accentColor,
  //           fontWeight: FontWeight.w500,
  //           fontSize: 15,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildStatItem(String label, String value, {bool isBoldValue = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
