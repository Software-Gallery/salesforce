import 'package:dio/dio.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/trn_sales_order_detail.dart';
import 'package:salesforce/models/trn_sales_order_header.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrmSalesOrderDetailServices {
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