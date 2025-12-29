import 'package:dio/dio.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/trn_sales_order_detail.dart';
import 'package:salesforce/models/trn_sales_order_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrmSalesOrderDetailServices {
  Future<int> addHeader(int id_departemen, int id_customer, String keterangan,) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int iduser = prefs.getInt('loginidkaryawan') ?? 0;
      final tglaktif = await prefs.getString('tglaktif') ?? '';
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-header'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-header';
      print(url);
      Map<String, dynamic> data = {
        'id_departemen': id_departemen,
        'id_customer': id_customer,
        'id_karyawan': iduser,
        'keterangan': keterangan,
        'tgl_sales_order' : tglaktif
      };      
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
      if (response.statusCode != 201) {
        print('gagal');
        throw(response.data['message']); 
      }

      print(response.data['data']['kode_sales_order']);
      return response.data['data']['kode_sales_order'];
    } catch (e) {
      print(e);
      throw(e);
    }
  }

  Future<int> addDetail(int kodesalesorder) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int iduser = prefs.getInt('loginidkaryawan') ?? 0;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-detail'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-detail';
      print(url);
      Map<String, dynamic> data = {
        'id_karyawan': iduser,
        'kode_sales_order' : kodesalesorder.toString()
      };      
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
      if (response.statusCode != 201) {
        print('gagal');
        throw(response.data['message']); 
      }

      print(response.data['data']['kode_sales_order']);
      return response.data['data']['kode_sales_order'];
    } catch (e) {
      print(e);
      throw(e);
    }
  }
  
  static Future<bool> updateHeader(String kode_sales_order, int id_departemen, int id_customer, String keterangan,) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int iduser = prefs.getInt('loginidkaryawan') ?? 0;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-header/update'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-header/update';
      print(url);
      Map<String, dynamic> data = {
        'kode_sales_order': kode_sales_order,
        'id_departemen': id_departemen,
        'id_customer': id_customer,
        'id_karyawan': iduser,
        'keterangan': keterangan,
        'no_ref' : '',
        'tgl_ref' : '',
      };      
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
      // if (response.statusCode != 201 || response.statusCode != 200) {
      //   print('gagal');
      //   throw(response.data['message']);
      // }
      return true;
    } catch (e) {
      print(e);
      throw(e);
    }
  }

  static Future<List<TrmSalesOrderHeader>> getHeaderAll() async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-header'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-header';
      print(url);
      final response = await Dio().get(url);
      Map<String, dynamic> responseData;
      if (response.statusCode != 200) {
        print('gagal');
        return [];
      }
      // responseData = response.data;
      List<dynamic> result = response.data;
      if (response.data == []) {
        print('data kosong');
        return [];
      }
      List<TrmSalesOrderHeader> listData = [];
      for (var data in result) {
        listData.add(TrmSalesOrderHeader.fromJson(data));
      }
      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }
  static Future<List<TrmSalesOrderHeader>> getHeaderById(String id) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-header'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-header';
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
      List<TrmSalesOrderHeader> listData = [];
      for (var data in result) {
        listData.add(TrmSalesOrderHeader.fromJson(data));
      }
      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }
  static Future<List<TrmSalesOrderDetail>> getDetailAll() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-detail'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-detail';
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
      List<TrmSalesOrderDetail> listData = [];
      for (var data in result) {
        listData.add(TrmSalesOrderDetail.fromJson(data));
      }
      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }
  static Future<List<TrmSalesOrderDetail>> getDetailById(String id) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/sales-order-detail'
        : url =  '$IPConnectShared:$IPPortShared/api/sales-order-detail';
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
      List<TrmSalesOrderDetail> listData = [];
      for (var data in result) {
        listData.add(TrmSalesOrderDetail.fromJson(data));
      }
      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }

}