import 'package:flutter/material.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/services/BarangService.dart';

class BarangProvider extends ChangeNotifier {
  List<BarangItem> itemLists = [];
  List<BarangItem> itemSearchLists = [];
  List<BarangItem> itemCartLists = [];
  bool isSearchLoaded = false;
  bool isBelanjaLoaded = false;

  void searchLoaded(bool isLoad) {
    isSearchLoaded = isLoad;
    notifyListeners();
  } 

  void belanjaLoaded() {
    isBelanjaLoaded = true;
    notifyListeners();
  }   

  Future<void> belanjaPopulateFromApi() async {
    List<BarangItem> listItem = await BarangService().getBarang();
    itemLists = listItem;
    notifyListeners();
  }

  Future<void> produkSearchPopulateFromApi(String keyword) async {
    List<BarangItem> listItem = await BarangService().getBarangByKeyword(keyword);
    itemSearchLists = listItem;
    notifyListeners();
  }

  void addCart(BarangItem item) {
    itemCartLists.add(item);
    notifyListeners(); 
  }

  void removeCart(int? itemId) {
    itemCartLists.removeWhere((barang) => barang.id_barang == itemId);
    notifyListeners(); 
  }  

  String? getNamaBarangById(int id) {
    try {
      return itemLists.firstWhere((barang) => barang.id_barang == id).nama_barang;
    } catch (e) {
      return null; 
    }
  }
  BarangItem? getBarangById(int searchId) {
    BarangItem? barangItem = itemLists.firstWhere(
      (item) => item.id_barang == searchId,
    );

    return barangItem;
   
  
  }

}
