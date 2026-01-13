import 'package:flutter/material.dart';
import 'package:salesforce/models/rute_item.dart';
import 'package:salesforce/services/RuteServices.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuteProvider with ChangeNotifier {
  List<RuteItem> itemLists = [];
  List<RuteItem> additionalLists = [];
  List<RuteItem> historiLists = [];
  List<RuteItem> tempItemLists = [];
  RuteItem? ruteCurrent;
  String currentSort = 'Customer A-Z';
  String currentSortAdditional = 'Customer A-Z';
  String currentSortHistory = 'Customer A-Z';
  int total = 0;
  int totalValueNota = 0;
  double averageSKU = 0;
  int distinctCustomerCount = 0;

  void hitungStatistik() {
    totalValueNota = historiLists.fold<int>(
      0,
      (sum, item) => sum + item.totalValue.round(),
    );

    if (historiLists.isNotEmpty) {
      final totalSku = historiLists.fold<double>(
        0,
        (sum, item) => sum + item.totalSKU,
      );
      averageSKU = (totalSku / historiLists.length);
      averageSKU = double.parse(averageSKU % 1 == 0
        ? averageSKU.toInt().toString()
        : averageSKU.toStringAsFixed(1));

    } else {
      averageSKU = 0;
    }


    distinctCustomerCount =
        historiLists.map((e) => e.id_customer).toSet().length;
  }

  Future<void> populateFromApi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idKaryawan = await prefs.getInt('loginidkaryawan'); 
    if (idKaryawan == null) return;
    List<RuteItem> listItem = await RuteServices.getAll(idKaryawan);
    itemLists = listItem;
    tempItemLists = listItem;
    // print(itemLists);
    notifyListeners();
  }

  Future<void> populateFromAdditional(int id, int page, String? nama) async {
    List<RuteItem> listItem = await RuteServices.getAdditional(id, page, nama);
    itemLists = listItem;
    additionalLists = listItem;
    // print(additionalLists);
    notifyListeners();
  }  

  Future<void> loadMoreAdditional(int id, int page, String nama) async {
    List<RuteItem> listItem = await RuteServices.getAdditional(id, page, nama);
    additionalLists.addAll(listItem);
    // print(additionalLists);
    notifyListeners();
  }  


  
  Future<void> populateHistoriFromApi(String startDate, String endDate, int id_customer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? idKaryawan = await prefs.getInt('loginidkaryawan'); 
    if (idKaryawan == null) return;
    List<RuteItem> listItem = await RuteServices().getHistori(startDate, endDate, idKaryawan, id_customer);
    historiLists = listItem;
    print(itemLists);
    hitungStatistik();
    notifyListeners();
  }

  void initCurrent() {
    ruteCurrent = RuteItem(id_departemen: -1, id_customer: -1, id_karyawan: -1, day1: -1, day2: -1, day3: -1, day4: -1, day5: -1, day6: -1, day7: -1, week_ganjil: -1, week_genap: -1, nama_customer: 'null', nama_departemen: 'null', kode_sales_order: '', tgl: '', jam_masuk: '', jam_keluar: '', latitude: 0.00, longitude: 0.00, keterangan: '', alamat: '', id_absen: -1, week: -1, tgl_aktif: DateTime.now(), tipe: 'J', status: '', kode_customer: '', latlong_customer: '', alamat_customer: '', jumlah_nota: 0, value_nota: 0, sisa_piutang: 0, jml_absen: 0, totalSKU: 0, totalValue: 0);
  }

  // Future<void> loadCurrent(String id_karyawan, String id_customer, String id_departemen) async {
  //   if (itemLists.isEmpty) {
  //     ruteCurrent = itemLists.firstWhere(
  //       (item) => item.id_customer == int.parse(id_customer) && item.id_departemen == int.parse(id_departemen) && item.id_karyawan == int.parse(id_karyawan),
  //     );
  //   }
  //   if (ruteCurrent!.nama_departemen == 'null') {
  //     await populateFromApi();
  //     ruteCurrent = itemLists.firstWhere(
  //       (item) => item.id_customer == int.parse(id_customer) && item.id_departemen == int.parse(id_departemen) && item.id_karyawan == int.parse(id_karyawan),
  //       orElse: () => RuteItem(id_departemen: -1, id_customer: -1, id_karyawan: -1, day1: -1, day2: -1, day3: -1, day4: -1, day5: -1, day6: -1, day7: -1, week_ganjil: -1, week_genap: -1, nama_customer: 'null', nama_departemen: 'null')
  //     );        
  //   }    
  // }

  Future<void> loadCurrent(int idKaryawan) async {
    ruteCurrent = await RuteServices.getCurrent(idKaryawan);
    notifyListeners();
  }

  Future<void> populateSearch(String keyword) async {
    tempItemLists = itemLists.where((item) =>
      item.nama_customer.toLowerCase().contains(keyword.toLowerCase())
    ).toList();
  }

  Future<void> populateTotal(String periode) async {
    total = await RuteServices.total(periode);
    notifyListeners();    
  }

  void setCurrent(RuteItem item) {
    ruteCurrent = item;
    notifyListeners();
  }

  void changeSort(String sort) {
    currentSort = sort;
    notifyListeners();
  }

  void changeSortAdditional(String sort) {
    currentSortAdditional = sort;
    notifyListeners();
  }

  void changeSortHistory(String sort) {
    currentSortHistory = sort;
    notifyListeners();
  }

  void sortByStatus(bool sortAdditional) {
    final list = sortAdditional ? additionalLists : tempItemLists;
    final sortBy = sortAdditional ? currentSortAdditional : currentSort;

    switch (sortBy) {
      case 'Customer A-Z':
        sortByCustomerNameAsc(list);
        break;

      case 'Customer Z-A':
        sortByCustomerNameDesc(list);
        break;

      case 'Order Created Terkecil':
        sortByNotaAmountAsc(list);
        break;

      case 'Order Created Terbesar':
        sortByNotaAmountDesc(list);
        break;

      case 'Overdue Terkecil':
        sortByOutstandingBalanceAsc(list);
        break;

      case 'Overdue Terbesar':
        sortByOutstandingBalanceDesc(list);
        break;

      default:
        print('Status tidak valid');
    }
  }

  void sortByStatusHistory() {
    final list = historiLists;
    final sortBy = currentSortHistory;

    switch (sortBy) {
      case 'Customer A-Z':
        sortByCustomerNameAsc(list);
        break;

      case 'Customer Z-A':
        sortByCustomerNameDesc(list);
        break;

      case 'Tanggal Terkecil':
        sortByTanggalAsc(list);
        break;

      case 'Tanggal Terbesar':
        sortByTanggalDesc(list);
        break;

      case 'Nomor Nota Terkecil':
        sortByNomorAsc(list);
        break;

      case 'Nomor Nota Terbesar':
        sortByNomorDesc(list);
        break;

      case 'Total SKU Terkecil':
        sortByTotalSKUAsc(list);
        break;

      case 'Total SKU Terbesar':
        sortByTotalSKUDesc(list);
        break;

      case 'Total Value Terkecil':
        sortByTotalValueAsc(list);
        break;

      case 'Total Value Terbesar':
        sortByTotalValueDesc(list);
        break;

      default:
        print('Status tidak valid');
    }
  }


  void sortByCustomerNameAsc(List items) {
    items.sort((a, b) => a.nama_customer.compareTo(b.nama_customer));
    notifyListeners();
  }

  void sortByCustomerNameDesc(List items) {
    items.sort((a, b) => b.nama_customer.compareTo(a.nama_customer));
    notifyListeners();
  }

  void sortByNotaAmountDesc(List items) {
    items.sort((a, b) => b.jumlah_nota.compareTo(a.jumlah_nota));
    notifyListeners();
  }

  void sortByNotaAmountAsc(List items) {
    items.sort((a, b) => a.jumlah_nota.compareTo(b.jumlah_nota));
    notifyListeners();
  }

  void sortByOutstandingBalanceDesc(List items) {
    items.sort((a, b) => b.sisa_piutang.compareTo(a.sisa_piutang));
    notifyListeners();
  }

  void sortByOutstandingBalanceAsc(List items) {
    items.sort((a, b) => a.sisa_piutang.compareTo(b.sisa_piutang));
    notifyListeners();
  }

  // Sort History
  void sortByTanggalAsc(List items) {
    items.sort((a, b) => a.tgl.compareTo(b.tgl));
    notifyListeners();
  }  

  void sortByTanggalDesc(List items) {
    items.sort((a, b) => b.tgl.compareTo(a.tgl));
    notifyListeners();
  }

  void sortByNomorAsc(List items) {
    items.sort((a, b) => a.kode_sales_order.compareTo(b.kode_sales_order));
    notifyListeners();
  }  

  void sortByNomorDesc(List items) {
    items.sort((a, b) => b.kode_sales_order.compareTo(a.kode_sales_order));
    notifyListeners();
  }

  void sortByTotalSKUAsc(List items) {
    items.sort((a, b) => a.totalSKU.compareTo(b.totalSKU));
    notifyListeners();
  }  

  void sortByTotalSKUDesc(List items) {
    items.sort((a, b) => b.totalSKU.compareTo(a.totalSKU));
    notifyListeners();
  }

  void sortByTotalValueAsc(List items) {
    items.sort((a, b) => a.totalValue.compareTo(b.totalValue));
    notifyListeners();
  }  

  void sortByTotalValueDesc(List items) {
    items.sort((a, b) => b.totalValue.compareTo(a.totalValue));
    notifyListeners();
  }


}
