import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_device_imei/flutter_device_imei.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/common_widgets/Utils.dart';
import 'package:salesforce/common_widgets/app_button.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/models/rute_item.dart';
import 'package:salesforce/provider/RuteProvider.dart';
import 'package:salesforce/screens/account/auth_page.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/screens/tambah_kunjungan.dart';
import 'package:salesforce/services/api_client.dart';
import 'package:salesforce/services/RuteServices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class AuthService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  var noVisit = '';
  var namaCustomer = '';
  int loginid = -1;
  RuteItem ruteCurrent = RuteItem(id_departemen: -1, id_customer: -1, id_karyawan: -1, day1: -1, day2: -1, day3: -1, day4: -1, day5: -1, day6: -1, day7: -1, week_ganjil: -1, week_genap: -1, nama_customer: 'null', nama_departemen: 'null', kode_sales_order: '', tgl: '', jam_masuk: '', jam_keluar: '', latitude: 0.00, longitude: 0.00, keterangan: '', alamat: '', id_absen: -1, week: -1, tgl_aktif: DateTime.now(), tipe: '', status: '', kode_customer: '', latlong_customer: '', alamat_customer: '', jumlah_nota: 0, value_nota: 0, sisa_piutang: 0, jml_absen: 0, totalSKU: 0, totalValue: 0);
  Widget handleAuthState() {
    setCabangPrefs();
    return const _AuthStateGate();
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
      String imei = '';
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          imei = await FlutterDeviceImei.instance.getIMEI() ?? '';
        }
      }
      bool isValidImei = await checkimei(imei);
      final token = await _secureStorage.read(key: 'token') ?? '';
      if (token.isEmpty) {
        return false;
      }
      bool isValidLogin = await checkIsTokenValid(token);
      final ok = isValidLogin && isValidImei;
      if (!ok) {
        await signOut();
      }
      return ok;
    } catch (e) {
      print(e);
      throw(e);
    }
  }

  Future<void> signOut() async {
    try {
      await _secureStorage.delete(key: 'token');
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loginid');
    await prefs.remove('loginidkaryawan');
    await prefs.remove('loginname');
    await prefs.remove('loginemail');
    await prefs.remove('tglaktif');
    await prefs.remove('kodesalesorder');
    await prefs.remove('email');
    await prefs.remove('username');
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
      final response = await ApiClient.instance.post(
        url,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 7),
          receiveTimeout: const Duration(seconds: 7),
        ),
      );
      if (response.statusCode != 200) {
        throw('${response.data is Map ? response.data['message'] ?? 'Gagal validasi IMEI' : 'Gagal validasi IMEI'}');
      }
      if (response.data is! Map) {
        return false;
      }
      return response.data['exist'] == true;
    } catch (e) {
      print('Error: $e');
      throw describeDioError(e);
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
      final response = await ApiClient.instance.post(
        url,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 7),
          receiveTimeout: const Duration(seconds: 7),
        ),
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        return false;
      }
      if (response.statusCode != 200) {
        throw('${response.data is Map ? response.data['message'] ?? 'Sesi tidak valid' : 'Sesi tidak valid'}');
      }
      if (response.data is! Map) {
        return false;
      }
      return response.data['exist'] == true;
    } catch (e) {
      print('Error: $e');
      throw describeDioError(e);
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
      final response = await ApiClient.instance.post(
        url,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      if (response.statusCode == 401 || response.statusCode == 403) {
        final msg = response.data is Map ? (response.data['message'] ?? 'Email atau password salah') : 'Email atau password salah';
        throw('$msg');
      }
      if (response.statusCode != 200 || response.data is! Map || !(response.data as Map).containsKey('token')) {
        final msg = response.data is Map ? (response.data['message'] ?? 'Login gagal') : 'Login gagal';
        print('Login failed: $msg');
        throw('$msg');
      }
      Map<String, dynamic> responseData = response.data;
      await getProfile(responseData['token']);
      await _secureStorage.write(key: 'token', value: responseData['token']);
      prefs.setInt('kodesalesorder', 0);
      print("Login success");
      return true;
    } catch (e) {
      print('Error: $e');
      throw describeDioError(e);
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
          : url = '$IPConnectShared:$IPPortShared/api/profile?token=$token';
      print("URL: $url");
      final response = await ApiClient.instance.get(
        url,
        options: Options(
          sendTimeout: const Duration(seconds: 7),
          receiveTimeout: const Duration(seconds: 7),
        ),
      );
      if (response.statusCode != 200) {
        final msg = response.data is Map ? (response.data['message'] ?? 'Gagal mengambil profil') : 'Gagal mengambil profil';
        print('Login failed: $msg');
        throw('$msg');
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
      throw describeDioError(e);
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

      final response = await ApiClient.instance.get(url);

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

      final response = await ApiClient.instance.get(url);

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

      final response = await ApiClient.instance.get(url);

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
      final response = await ApiClient.instance.get(url);
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

class _AuthStateGate extends StatefulWidget {
  const _AuthStateGate({Key? key}) : super(key: key);

  @override
  State<_AuthStateGate> createState() => _AuthStateGateState();
}

class _AuthStateGateState extends State<_AuthStateGate> {
  late Future<bool> _sessionFuture;
  Future<bool>? _visitFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _runCheckSession();
  }

  Future<bool> _runCheckSession() {
    return AuthService().checkLoginSession().timeout(
      const Duration(seconds: 7),
      onTimeout: () => throw 'Koneksi sedang bermasalah, periksa koneksi internet Anda.',
    );
  }

  Future<bool> _runCheckVisit() {
    return AuthService().getCurrentNoVisit(context).timeout(
      const Duration(seconds: 7),
      onTimeout: () => throw 'Koneksi sedang bermasalah, periksa koneksi internet Anda.',
    );
  }

  void _retry() {
    setState(() {
      _visitFuture = null;
      _sessionFuture = _runCheckSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return NoInternetScreen(
            message: snapshot.error.toString(),
            onRetry: _retry,
          );
        }
        if (snapshot.data == true) {
          _visitFuture ??= _runCheckVisit();
          return FutureBuilder<bool>(
            future: _visitFuture,
            builder: (context, visitSnap) {
              if (visitSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              if (visitSnap.hasError) {
                return NoInternetScreen(
                  message: visitSnap.error.toString(),
                  onRetry: _retry,
                );
              }
              if (visitSnap.data == true) {
                return TambahKunjungan(
                  jam: DateFormat('HH:mm:ss').format(DateTime.now()),
                  isMasuk: false,
                );
              }
              return DashboardScreen();
            },
          );
        }
        return AuthPage();
      },
    );
  }
}

class NoInternetScreen extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NoInternetScreen({
    Key? key,
    required this.onRetry,
    this.message = 'Tidak ada koneksi internet.',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 96, color: Colors.grey),
                const SizedBox(height: 24),
                const Text(
                  'Tidak Ada Koneksi Internet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Refresh',
                  onPressed: onRetry,
                  trailingWidget: const Icon(Icons.refresh, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
