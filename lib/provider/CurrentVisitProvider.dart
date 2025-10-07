
import 'package:flutter/material.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/models/trn_sales_order_detail.dart';
import 'package:salesforce/services/TrnSalesOrderServices.dart';

class CurrentVisitProvider with ChangeNotifier {
  // List<TrmSalesOrderDetail> itemLists = [];
  String noVisit = '';
  String jam = '';
  List<BarangItem> itemLists = [];

  void setnoVisit(String pnoVisit) {
    noVisit = pnoVisit;
    notifyListeners();
  } 

  void setjam(String pjam) {
    jam = pjam;
    notifyListeners();
  } 

  void additemLists(BarangItem pItem) {
    itemLists.add(pItem);
    notifyListeners();
  } 
}
