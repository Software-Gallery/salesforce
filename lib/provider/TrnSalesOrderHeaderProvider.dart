import 'package:flutter/material.dart';
import 'package:salesforce/models/trn_sales_order_detail.dart';
import 'package:salesforce/models/trn_sales_order_header.dart';
import 'package:salesforce/services/TrnSalesOrderServices.dart';

class TrmSalesOrderHeaderProvider with ChangeNotifier {
  List<TrmSalesOrderHeader> itemLists = [];

  Future<void> populateFromApi() async {
    List<TrmSalesOrderHeader> listItem =
        await TrmSalesOrderDetailServices.getHeaderAll();
    itemLists = listItem;
    notifyListeners();
  }

  Future<void> populateDetail(String nomor) async {
    List<TrmSalesOrderDetail> listItemDetail =
        await TrmSalesOrderDetailServices.getDetailById(nomor);

    TrmSalesOrderHeader itemToUpdated =
        itemLists.firstWhere((orderjualh) => orderjualh.kode_sales_order == nomor);
    itemToUpdated.listDetail = listItemDetail;
    notifyListeners();
  }

  void deleteItem(String nomor) {
    itemLists.removeWhere(
      (item) => item.kode_sales_order == nomor,
    );
    notifyListeners();
  }
}
