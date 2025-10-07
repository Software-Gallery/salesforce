
import 'package:flutter/material.dart';
import 'package:salesforce/models/trn_sales_order_detail.dart';
import 'package:salesforce/services/TrnSalesOrderServices.dart';

class TrmSalesOrderDetailProvider with ChangeNotifier {
  List<TrmSalesOrderDetail> itemLists = [];

  Future<void> populateFromApi() async {
    List<TrmSalesOrderDetail> listItem =
        await TrmSalesOrderDetailServices.getDetailAll();
    itemLists = listItem;
    print(itemLists);
    notifyListeners();
  }
  Future<void> populateById(String id) async {
    List<TrmSalesOrderDetail> listItem =
        await TrmSalesOrderDetailServices.getDetailById(id);
    itemLists = listItem;
    print(itemLists);
    notifyListeners();
  }
}
