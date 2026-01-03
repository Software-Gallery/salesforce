import 'package:dio/dio.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/barang_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BarangService {
  Future<List<BarangItem>> getBarang() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int iduser = prefs.getInt('loginidkaryawan') ?? 0;      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/barang?id=$iduser'
        : url =  '$IPConnectShared:$IPPortShared/api/barang?id=$iduser';
      
      print(url);

      final response = await Dio().get(url);

      Map<String, dynamic> responseData;

      if (response.statusCode != 200) {
        print('gagal');
        return [];
      }

      responseData = response.data;

      List<dynamic> result = responseData['data'];

      if (responseData['data'] == []) {
        print('data kosong');
        return [];
      }

      List<BarangItem> listData = [];
      for (var data in result) {
        listData.add(BarangItem.fromJson(data));
      }

      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<BarangItem>> getBarangByKeyword(String keyword) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/searchBarang?keyword=${keyword}'
        : url =  '$IPConnectShared:$IPPortShared/api/searchBarang?keyword=${keyword}';
      
      print(url);

      final response = await Dio().get(url);

      Map<String, dynamic> responseData;

      if (response.statusCode != 200) {
        print('gagal');
        return [];
      }

      responseData = response.data;

      List<dynamic> result = responseData['data'];

      if (responseData['data'] == []) {
        print('data kosong');
        return [];
      }

      List<BarangItem> listData = [];
      for (var data in result) {
        listData.add(BarangItem.fromJson(data));
      }

      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<BarangItem>> getBarangKeranjang() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;

      // int iduser = prefs.getInt('loginidkaryawan') ?? 0;
      int kodeSalesOrder = prefs.getInt('kodesalesorder') ?? 0;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/keranjang?id=${kodeSalesOrder}'
        : url =  '$IPConnectShared:$IPPortShared/api/keranjang?id=${kodeSalesOrder}';
      
      print(url);

      final response = await Dio().get(url);

      Map<String, dynamic> responseData;

      if (response.statusCode != 200) {
        print('gagal');
        return [];
      }

      responseData = response.data;

      List<dynamic> result = responseData['data'];

      if (responseData['data'] == []) {
        print('data kosong');
        return [];
      }

      List<BarangItem> listData = [];
      for (var data in result) {
        listData.add(BarangItem.fromJson(data));
      }

      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List<BarangItem>> getBarangTrnDetail(String nomor) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/getTrnDetail?kode=${nomor}'
        : url =  '$IPConnectShared:$IPPortShared/api/getTrnDetail?kode=${nomor}';
      
      print(url);

      final response = await Dio().get(url);

      Map<String, dynamic> responseData;

      if (response.statusCode != 200) {
        print('gagal');
        return [];
      }

      responseData = response.data;

      List<dynamic> result = responseData['data'];

      if (responseData['data'] == []) {
        print('data kosong');
        return [];
      }

      List<BarangItem> listData = [];
      for (var data in result) {
        listData.add(BarangItem.fromJson(data));
      }

      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }

  // Future<bool> addBarangKeranjang(int idBarang, double qty) async {
  //   try {
  //     final SharedPreferences prefs = await SharedPreferences.getInstance();
  //     var IPConnectShared = AppConfig.api_ip;
  //     var IPPortShared = AppConfig.api_port;
  //     int iduser = prefs.getInt('loginidkaryawan') ?? 0;
  //     String url = '';
  //     IPPortShared == ''
  //       ? url =  '$IPConnectShared/api/addKeranjang'
  //       : url =  '$IPConnectShared:$IPPortShared/api/addKeranjang';
  //     print(url);
  //     Map<String, dynamic> data = {
  //       'id_karyawan': iduser,
  //       'id_barang': idBarang,
  //       'qty': qty
  //     };      
  //     final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
  //     if (response.statusCode != 200 || response.data['statusCode'] != 200) {
  //       print('gagal');
  //       throw(response.data['message']);
  //     }
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     throw(e);
  //   }
  // }

  Future<bool> addBarangKeranjang(int idBarang, String qty, double? disc_cash, double? disc_perc, String ket) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int iduser = prefs.getInt('loginidkaryawan') ?? 0;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/addKeranjang'
        : url =  '$IPConnectShared:$IPPortShared/api/addKeranjang';
      print(url);
      Map<String, dynamic> data = {
        'kode_sales_order': iduser,
        'id_barang': idBarang,
        'qty': qty,
        'disc_cash': (disc_cash ?? 0).toInt(),
        'disc_perc': (disc_perc ?? 0).toInt(),
        'ket': ket,
      };      
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
      if (response.statusCode != 200 || response.data['statusCode'] != 200) {
        print('gagal');
        throw(response.data['message']);
      }
      return true;
    } catch (e) {
      print(e);
      throw(e);
    }
  }

  Future<bool> editTrnKeranjang(String nomor, int idBarang, String qty, double? disc_cash, double? disc_perc, String ket) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-detail/update'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-detail/update';
      print(url);
      Map<String, dynamic> data = {
        'kode_sales_order': nomor,
        'id_barang': idBarang,
        'qty': qty,
        'disc_cash': (disc_cash ?? 0).toInt(),
        'disc_perc': (disc_perc ?? 0).toInt(),
        'ket': ket,
      };      
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
      if (response.statusCode != 200 || response.data['statusCode'] != 200) {
        print('gagal');
        throw(response.data['message']);
      }
      return true;
    } catch (e) {
      print(e);
      throw(e);
    }
  }  

  Future<bool> removeBarangKeranjang(int idBarang, String status) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int kodeSalesOrder = prefs.getInt('kodesalesorder') ?? 0;
      // int iduser = prefs.getInt('loginidkaryawan') ?? 0;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-detail/delete'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-detail/delete';
      
      print(url);

      Map<String, dynamic> data = {
        'kode_sales_order': kodeSalesOrder,
        'id_barang': idBarang,
        'status': status,
      };      
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));

      if (response.statusCode != 200) {
        print('gagal');
        throw(response.data['message']);
      }

      return true;
    } catch (e) {
      print(e);
      throw(e);
    }
  }
}