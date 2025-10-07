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
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/barang'
        : url =  '$IPConnectShared:$IPPortShared/api/barang';
      
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

  Future<List<Map<String,dynamic>>> getBarangCart() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;

      int iduser = prefs.getInt('iduser') ?? 0;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/getCart?id=${iduser}'
        : url =  '$IPConnectShared:$IPPortShared/api/getCart?id=${iduser}';
      
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
      List<Map<String,dynamic>> cartDataList = [];
      for (var data in result) {
        listData.add(BarangItem.fromJson(data));
      }

      int counter=0;
      // Populate cart dari barang item list
      for(var item in result) {
        cartDataList.add({
          "barang": listData[counter],
          "qty": item['qty'],
        });

        counter++;
      }
      return cartDataList;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<bool> addBarangCart(int idBarang, qty) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;

      int iduser = prefs.getInt('iduser') ?? 0;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/addCart?memberId=${iduser}&barangId=${idBarang}&qty=$qty'
        : url =  '$IPConnectShared:$IPPortShared/api/addCart?memberId=${iduser}barangId=${idBarang}';
      
      print(url);

      final response = await Dio().get(url);

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

  Future<bool> updateCartQty(int idBarang, qty) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;

      int iduser = prefs.getInt('iduser') ?? 0;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/updateCartQty?memberId=${iduser}&barangId=${idBarang}&qty=$qty'
        : url =  '$IPConnectShared:$IPPortShared/api/updateCartQty?memberId=${iduser}&barangId=${idBarang}&qty=$qty';
      
      print(url);

      final response = await Dio().get(url);

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

  Future<bool> remaoveBarangCart(int idBarang) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;

      int iduser = prefs.getInt('iduser') ?? 0;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/removeCart?memberId=${iduser}&barangId=${idBarang}'
        : url =  '$IPConnectShared:$IPPortShared/api/removeCart?memberId=${iduser}barangId=${idBarang}';
      
      print(url);

      final response = await Dio().get(url);

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

  Future<bool> removeAllCart() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;

      int iduser = prefs.getInt('iduser') ?? 0;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/removeAllCart?memberId=${iduser}'
        : url =  '$IPConnectShared:$IPPortShared/api/removeAllCart?memberId=${iduser}';
      
      print(url);

      final response = await Dio().get(url);

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
}