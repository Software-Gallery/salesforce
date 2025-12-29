import 'package:flutter/material.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:salesforce/services/BarangService.dart';

class BarangProvider extends ChangeNotifier {
  List<BarangItem> itemLists = [];
  List<BarangItem> itemSearchLists = [];
  List<BarangItem> itemCartLists = [];
  List<BarangItem> itemtrnLists = [];
  bool isSearchLoaded = false;
  bool isBelanjaLoaded = false;
  double subtotaltambah = 0;
  double totaltambah = 0;
  double subtotalview = 0;
  double totalview = 0;
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
    itemSearchLists = itemLists;
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

  Future<void> produkCartPopulateFromApi() async {
    List<BarangItem> listItem = await BarangService().getBarangKeranjang();
    itemCartLists = listItem;
    HitungTotalTambah();
    notifyListeners();
  }

  void HitungTotalTambah() {
    subtotaltambah = 0;
    totaltambah = 0;
    itemCartLists.forEach((item) {
      subtotaltambah += item.subtotal;
      totaltambah += item.total;
    });
    notifyListeners();
  }
  
  void HitungTotalView() {
    subtotalview = 0;
    totalview = 0;
    itemtrnLists.forEach((item) {
      subtotalview += item.subtotal;
      totalview += item.total;
    });
    notifyListeners();
  }

  Future<void> produkTrnPopulateFromApi(String nomor) async {
    List<BarangItem> listItem = await BarangService().getBarangTrnDetail(nomor);
    itemtrnLists = listItem;
    HitungTotalView();
    notifyListeners();
  }

  void updateQty(int itemId, double newQty) {
    // Mencari barang berdasarkan id
    BarangItem barang = barangList.firstWhere(
      (item) => item.id_barang == itemId, 
      orElse: () => BarangItem(id_barang: -1, kode_barang: '1', id_departemen: 1, nama_barang: '', satuan_besar: 1, satuan_tengah: 1, satuan_kecil: 0, konversi_besar: 0, konversi_tengah: 0, gambar: '', is_aktif: 1, harga: 0, qty_besar: 0, qty_tengah: 0, qty_kecil: 0, disc_cash: 0, disc_perc: 0, ket_detail: '', subtotal: 0, total: 0),
    );

    // Jika barang ditemukan (id != -1)
    if (barang.id_barang != -1) {
      barang.qty_kecil = newQty;
      print('Barang ${barang.nama_barang} dengan ID ${barang.id_barang} berhasil diupdate. Qty baru: ${barang.qty_kecil}');
    } else {
      print('Barang dengan ID $itemId tidak ditemukan.');
    }
  }  

  String loadQty(int itemId) {
    BarangItem barang = itemCartLists.firstWhere(
      (item) => item.id_barang == itemId, 
      orElse: () => BarangItem(id_barang: -1, kode_barang: '1', id_departemen: 1, nama_barang: '', satuan_besar: 1, satuan_tengah: 1, satuan_kecil: 0, konversi_besar: 0, konversi_tengah: 0, gambar: '', is_aktif: 1, harga: 0, qty_besar: 0, qty_tengah: 0, qty_kecil: 0, disc_cash: 0, disc_perc: 0, ket_detail: '', subtotal: 0, total: 0),
    );

    if (barang.qty_besar+barang.qty_tengah+barang.qty_kecil > 0) {
      return "${barang.qty_besar.toInt()}.${barang.qty_tengah.toInt()}.${barang.qty_kecil.toInt()}";
    } else {
      return "";
    }
  }  

  String loadTrnQty(int itemId) {
    BarangItem barang = itemtrnLists.firstWhere(
      (item) => item.id_barang == itemId, 
      orElse: () => BarangItem(id_barang: -1, kode_barang: '1', id_departemen: 1, nama_barang: '', satuan_besar: 1, satuan_tengah: 1, satuan_kecil: 0, konversi_besar: 0, konversi_tengah: 0, gambar: '', is_aktif: 1, harga: 0, qty_besar: 0, qty_tengah: 0, qty_kecil: 0, disc_cash: 0, disc_perc: 0, ket_detail: '', subtotal: 0, total: 0),
    );

    if (barang.qty_besar+barang.qty_tengah+barang.qty_kecil > 0) {
      return "${barang.qty_besar.toInt()}.${barang.qty_tengah.toInt()}.${barang.qty_kecil.toInt()}";
    } else {
      return "";
    }
  }    

  Future<void> populateSearch(String keyword) async {
    itemSearchLists = itemLists.where((item) =>
      item.nama_barang.toLowerCase().contains(keyword.toLowerCase()) ||
      item.kode_barang.toLowerCase().contains(keyword.toLowerCase())
    ).toList();
    notifyListeners();
  }
}
