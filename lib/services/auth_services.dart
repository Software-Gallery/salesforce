import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/provider/CurrentVisitProvider.dart';
import 'package:salesforce/screens/account/auth_page.dart';
import 'package:salesforce/screens/dashboard/dashboard_screen.dart';
import 'package:salesforce/screens/home/home_screen.dart';
import 'package:salesforce/screens/tambah_kunjungan.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthService {
  var noVisit = '';
  handleAuthState() {
    setCabangPrefs();
    return FutureBuilder(
        future: checkLoginSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Cek jika internet loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Cek jika terdapat error pada autentikasi
            return const Center(child: Text('Something went wrong!'));
          } else if (snapshot.data == true) {
            // Cek jika autentikasi berhasil
            return FutureBuilder<bool>(
              future: getCurrentNoVisit(context),  // Memanggil getCurrentNoVisit disini
              builder: (context, noVisitSnapshot) {
                if (noVisitSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (noVisitSnapshot.hasError) {
                  return const Center(child: Text('Error checking visit status'));
                } else if (noVisitSnapshot.data == true) {
                  return TambahKunjungan(noVisit: noVisit, jam: DateFormat('HH:mm:ss').format(DateTime.now()),);
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
    final prefs = await SharedPreferences.getInstance();
    noVisit = prefs.getString('noVisit') ?? '';          
    final currentVisitProvider = Provider.of<CurrentVisitProvider>(context, listen: false);
    currentVisitProvider.noVisit =  noVisit ?? '';
    return (noVisit != '');
  }

  Future<bool> checkLoginSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');

    print("shared cek login$email");

    // Pemeriksaan sesi login sesuai kebutuhan Anda
    if (email != null &&
        email != "Not logged in"&&
        email != '') {
      return true; // Pengguna sudah login
    } else {
      return false; // Pengguna belum login
    }
  }

  Future<void> setCabangPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    String cabangprefs = prefs.getString('cabangname') ?? '';
    if (cabangprefs == '') {
      prefs.setString('cabangname', 'Supermarket A');
    }
  }

  Future<bool> auth(String $email, String $pass) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // var IPConnectShared = await prefs.getString('IPADDRESS');
      // var IPPortShared = await prefs.getString('IPPORT');
      var IPConnectShared = AppConfig.api_ip;
      var IPPortShared = AppConfig.api_port;
      
      String url = '';
      IPPortShared == ''
        ? url =  '$IPConnectShared/api/members/auth?email=${$email}&password=${$pass}'
        : url =  '$IPConnectShared:$IPPortShared/api/members/auth?email=${$email}&password=${$pass}';
      
      print(url);

      final response = await Dio().get(url);

      Map<String, dynamic> responseData;

      if (response.statusCode != 200 || response.data['statusCode'] != 200) {
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



}
