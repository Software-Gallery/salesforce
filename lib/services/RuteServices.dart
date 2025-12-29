import 'dart:io';

import 'package:dio/dio.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/rute_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RuteServices {
  static Future<List<RuteItem>> getAll(int id) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/customer-rute-by-id?id=$id'
        : url =  '$IPConnectShared:$IPPortShared/api/customer-rute-by-id?id=$id';
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
      List<RuteItem> listData = [];
      for (var data in result) {
        listData.add(RuteItem.fromJson(data));
      }
      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<RuteItem>> getAdditional(int id, int page, String? nama) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      nama = Uri.encodeComponent(nama ?? '');
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/customer-rute-all?id=$id&page=$page'
        : url =  '$IPConnectShared:$IPPortShared/api/customer-rute-all?id=$id&page=$page';
      if (!(nama == '')) {
        url += '&nama=$nama';
      }  
      print(url);
      final response = await Dio().get(url);
      Map<String, dynamic> responseData;
      if (response.statusCode != 200) {
        print('gagal');
        return [];
      }
      responseData = response.data;
      List<dynamic> result = responseData['data']['data'];
      if (responseData['data']['data'] == []) {
        print('data kosong');
        return [];
      }
      List<RuteItem> listData = [];
      for (var data in result) {
        listData.add(RuteItem.fromJson(data));
      }
      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }  

  static Future<RuteItem?> getCurrent(int id) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/checkAbsen?id=$id'
        : url =  '$IPConnectShared:$IPPortShared/api/checkAbsen?id=$id';
      print(url);
      final response = await Dio().get(url);
      Map<String, dynamic> responseData;
      if (response.statusCode != 200) {
        print('gagal');
        return null;
      }
      responseData = response.data;
      if (responseData['data'] == []) {
        print('data kosong');
        return null;
      }
      return RuteItem.fromJson(responseData['data']);
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<String> getTglAktif(int id) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/customer-rute-tgl-aktif?id=$id'
        : url =  '$IPConnectShared:$IPPortShared/api/customer-rute-tgl-aktif?id=$id';
      print(url);
      final response = await Dio().get(url);
      if (response.statusCode != 200) {
        print('gagal');
        return '';
      }
      print(response.data['tgl_aktif']);
      return response.data['tgl_aktif'];
    } catch (e) {
      print(e);
      return '';
    }
  }

  static Future<int> addAbsen(int id_customer, int id_departemen, String tgl, String jam_masuk, String latitude, String longitude, String keterangan, String alamat, String tipe) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int iduser = prefs.getInt('loginidkaryawan') ?? 0;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/absen'
        : url =  '$IPConnectShared:$IPPortShared/api/absen';
      
      Map<String, dynamic> data = {
        'id_karyawan': iduser,
        'id_customer': id_customer,
        'id_departemen': id_departemen,
        'tgl': tgl,
        'jam_masuk': jam_masuk,
        'latitude': latitude == '' ? '-0.0' : latitude,
        'longitude': longitude == '' ? '-0.0' : longitude,
        'keterangan': keterangan,
        'alamat': alamat,
        'tipe': tipe,
      };
      var response = await Dio(BaseOptions(connectTimeout: Duration(seconds:15))).post(url, data: data, options: Options (validateStatus: (_) => true, responseType: ResponseType.json,));

      if (!(response.data is Map)) {
        if (response.data.toLowerCase().contains('html')) {
          response = await Dio(BaseOptions(connectTimeout: Duration(seconds: 10))).post(url, data: data, options: Options (validateStatus: (_) => true, responseType: ResponseType.json,));
        }
      }

      if (response.statusCode != 201) {
        print('gagal');
        throw(response.data['message']);
      }

      return response.data['data']['id_absen'];
    } catch (e) {
      print(e);
      throw(e);
    }
  }

  static Future<bool> selesaiAbsen(int kodeSalesOrder) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int idAbsen = prefs.getInt('idAbsen') ?? 0;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/selesaiabsen'
        : url =  '$IPConnectShared:$IPPortShared/api/selesaiabsen';
      
      Map<String, dynamic> data = {
        'id_absen': idAbsen,
        'kode_sales_order': kodeSalesOrder 
      };
      var response = await Dio(BaseOptions(connectTimeout: Duration(seconds: 10))).post(url, data: data, options: Options (validateStatus: (_) => true, responseType: ResponseType.json,));

      if (!(response.data is Map)) {
        if (response.data.toLowerCase().contains('html')) {
          response = await Dio(BaseOptions(connectTimeout: Duration(seconds: 10))).post(url, data: data, options: Options (validateStatus: (_) => true, responseType: ResponseType.json,));
        }
      }      

      if (response.statusCode != 201) {
        print('gagal');
        throw(response.data['message']);
      }
      return true;
    } catch (e) {
      print(e);
      throw(e);
    }
  }

  Future<void> sendImageToServer(File imageFile, String kodeSalesOrder) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/upload-image'
        : url =  '$IPConnectShared:$IPPortShared/api/upload-image';

      FormData formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imageFile.path, filename: 'image.jpg'),
        'kode_sales_order': kodeSalesOrder
      });

      Response response = await Dio().post(url, data: formData);

      if (response.statusCode == 200) {
        print('Upload success: ${response.data}');
      } else {
        print('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred during image upload: $e');
    }
  } 

  static Future<int> total(String periode) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      int idAbsen = prefs.getInt('loginidkaryawan') ?? 0;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/absen-total?periode=${periode}&id=${idAbsen}'
        : url =  '$IPConnectShared:$IPPortShared/api/absen-total?periode=${periode}&id=${idAbsen}';
      final response = await Dio().get(url, options: Options (validateStatus: (_) => true, responseType: ResponseType.json));

      if (response.statusCode != 200) {
        print('gagal');
        throw(response.data['message']);
      }
      return response.data['data'];
    } catch (e) {
      print(e);
      throw(e);
    }
  }

  Future<List<RuteItem>> getHistori(String startDate, String endDate, int id) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/absen-histori?id=$id&startDate=${startDate}&endDate=${endDate}'
        : url =  '$IPConnectShared:$IPPortShared/api/absen-histori?id=$id&startDate=${startDate}&endDate=${endDate}';
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
      List<RuteItem> listData = [];
      for (var data in result) {
        listData.add(RuteItem.fromJson(data));
      }
      return listData;
    } catch (e) {
      print(e);
      return [];
    }
  }

}