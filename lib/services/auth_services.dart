import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/rute_item.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/screens/account/auth_page.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/screens/tambah_kunjungan.dart';
import 'package:salesforce/services/RuteServices.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  var noVisit = '';
  var namaCustomer = '';
  int loginid = -1;
  RuteItem ruteCurrent = RuteItem(id_departemen: -1, id_customer: -1, id_karyawan: -1, day1: -1, day2: -1, day3: -1, day4: -1, day5: -1, day6: -1, day7: -1, week_ganjil: -1, week_genap: -1, nama_customer: 'null', nama_departemen: 'null', kode_sales_order: '', tgl: '', jam_masuk: '', jam_keluar: '', latitude: 0.00, longitude: 0.00, keterangan: '', alamat: '', id_absen: -1, week: -1, tgl_aktif: DateTime.now(), tipe: '', status: '', kode_customer: '', latlong_customer: '', alamat_customer: '', jumlah_nota: 0, value_nota: 0, sisa_piutang: 0, jml_absen: 0, totalSKU: 0, totalValue: 0);
  handleAuthState() {
    setCabangPrefs();
    return FutureBuilder(
        future: checkLoginSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return const Scaffold(body: Center(child: Text('Something went wrong!')));
          } else if (snapshot.data == true) {
            return FutureBuilder<bool>(
              future: getCurrentNoVisit(context),
              builder: (context, noVisitSnapshot) {
                if (noVisitSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                } else if (noVisitSnapshot.hasError) {
                  return const Scaffold(body: Center(child: Text('Error checking visit status')));
                } else if (noVisitSnapshot.data == true) {
                  return TambahKunjungan(jam: DateFormat('HH:mm:ss').format(DateTime.now()), isMasuk: false,);
                } else {
                  return DashboardScreen();
                }
              },
            );
          } else {
            return AuthPage();
          }
        });
  }

  Future<bool> getCurrentNoVisit(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      loginid = prefs.getInt('loginidkaryawan') ?? -1;          
      final ruteProvider = Provider.of<RuteProvider>(context, listen: false);
      ruteProvider.initCurrent();
      await ruteProvider.loadCurrent(loginid);
      String tglaktif = await RuteServices.getTglAktif(loginid);
      prefs.setString('tglaktif', tglaktif);
      if (ruteProvider.ruteCurrent == null) {
        return false;
      }
      return (ruteProvider.ruteCurrent!.nama_departemen != 'null');
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> checkLoginSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final imei = await FlutterDeviceImei.instance.getIMEI();
      bool isValidImei = await checkimei(imei ?? '');
      final email = prefs.getString('token');
      bool isValidLogin = await checkIsTokenValid(email ?? '');
      // if (email != null && email != '') {
      //   return true;
      // } else {
      //   return false;
      // }      
      return isValidLogin && isValidImei;
    } catch (e) {
      print(e);
      throw(e);
    }
  }

  Future<bool> checkimei(String imei) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/isValidImei'
        : url =  '$IPConnectShared:$IPPortShared/api/isValidImei';
      Map<String, dynamic> data = {
        'imei': imei,
      };
      print("URL: $url");
      print("Request Data: $data");
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
      Map<String, dynamic> responseData = response.data;
      return responseData['exist'];      
    } catch (e) {
      print('Error: $e');
      throw e;      
    }
  }

  Future<bool> checkIsTokenValid(String token) async {
    try {
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/isValidLogin'
        : url =  '$IPConnectShared:$IPPortShared/api/isValidLogin';
      Map<String, dynamic> data = {
        'token': token,
      };
      print("URL: $url");
      print("Request Data: $data");
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
      Map<String, dynamic> responseData = response.data;
      return responseData['exist'];      
    } catch (e) {
      print('Error: $e');
      throw e;      
    }
  }

  Future<void> setCabangPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String cabangprefs = prefs.getString('cabangname') ?? '';
    if (cabangprefs == '') {
      prefs.setString('cabangname', 'Supermarket A');
    }
  }

  Future<bool> auth(String email, String password, String imei) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared.isEmpty
          ? url = '$IPConnectShared/api/login'
          : url = '$IPConnectShared:$IPPortShared/api/login';
      Map<String, dynamic> data = {
        'email': email,
        'password': password,
        'imei': imei,
      };
      print("URL: $url");
      print("Request Data: $data");
      final response = await Dio().post(url, data: data, options: Options (validateStatus: (_) => true));
      if (response.statusCode != 200 || !response.data.containsKey('token')) {
        print('Login failed: ${response.data['message']}');
        throw("${response.data['message']}");
      }
      Map<String, dynamic> responseData = response.data;
      await getProfile(responseData['token']);
      prefs.setString('token', responseData['token']); 
      print("Login success");
      return true;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<bool> getProfile(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared.isEmpty
          ? url = '$IPConnectShared/api/profile?token=$token'
          : url = '$IPConnectShared:$IPPortShared/api/profile?$token';
      print("URL: $url");
      final response = await Dio().get(url, options: Options (validateStatus: (_) => true));
      if (response.statusCode != 200) {
        print('Login failed: ${response.data['message']}');
        throw("${response.data['message']}");
      }
      Map<String, dynamic> responseData = response.data;
      print("Login success");
      prefs.setInt('loginid', responseData['data']['id']); 
      prefs.setInt('loginidkaryawan', responseData['data']['id_karyawan']); 
      prefs.setString('loginname', responseData['data']['name']); 
      prefs.setString('loginemail', responseData['data']['email']); 
      return true;
    } catch (e) {
      print('Error: $e');
      throw e;
    }
  }

  Future<bool>  signUp({required String email, required String pass, required String username}) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/members/signup?email=${email}&password=${pass}&username=${username}'
        : url =  '$IPConnectShared:$IPPortShared/api/members/signup?email=${email}&password=${pass}&username=${username}';
      
      print(url);

      final response = await Dio().get(url);

      Map<String, dynamic> responseData;

      if ( response.statusCode != 200 || response.data['statusCode'] != 200) {
        print(response.data['message']);
        throw("${response.data['message']}");
      }

      responseData = response.data;

      prefs.setString('email', responseData['data']['email']);
      prefs.setString('username', responseData['data']['username']);
      prefs.setInt('iduser', responseData['data']['id']);

      return true;
    } catch (e) {
      throw(e);
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';

      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/send-email-verification?email=${email}'
        : url =  '$IPConnectShared:$IPPortShared/api/send-email-verification?email=${email}';
      
      print(url);

      final response = await Dio().get(url);

      Map<String, dynamic> responseData;

      if (response.statusCode != 200 || response.data['statusCode'] != 200) {
        print(response.data['message']);
        throw("${response.data['message']}");
      }
      responseData = response.data;
      return true;
    } catch (e) {
      throw(e);
    }
  }

  Future<bool> verifyEmail(String kode) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('email') ?? '';

      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/verify-email?email=${email}&code=${kode}'
        : url =  '$IPConnectShared:$IPPortShared/api/verify-email?email=${email}&code=${kode}';
      
      print(url);

      final response = await Dio().get(url);

      Map<String, dynamic> responseData;

      if (response.statusCode != 200 || response.data['statusCode'] != 200) {
        print(response.data['message']);
        throw("${response.data['message']}");
      }
      responseData = response.data;
      return true;
    } catch (e) {
      throw(e);
    }
  }

  Future<void> checkVersion(VoidCallback showDialog) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/setting-info'
        : url =  '$IPConnectShared:$IPPortShared/api/setting-info';
      print(url);
      final response = await Dio().get(url);
      Map<String, dynamic> responseData;
      responseData = response.data;
      final info = await PackageInfo.fromPlatform();

      bool isBelow = needUpdate(info.version, responseData['data']['min_version']);
      
      if (isBelow) {
        showDialog();
      }
    } catch (e) {
      throw(e);
    }
  }

  bool needUpdate(String currentVersion, String minVersion) {
    List<int> current = currentVersion.split('.').map(int.parse).toList();
    List<int> min = minVersion.split('.').map(int.parse).toList();

    // Samakan panjang list
    int maxLength = current.length > min.length ? current.length : min.length;
    while (current.length < maxLength) current.add(0);
    while (min.length < maxLength) min.add(0);

    // Bandingkan satu per satu
    for (int i = 0; i < maxLength; i++) {
      if (current[i] < min[i]) return true;  // WAJIB UPDATE
      if (current[i] > min[i]) return false; // SUDAH MEMENUHI
    }

    return false;
  }




}
