import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class Utils {
  static void showActionSnackBar(
    {
      required BuildContext context, 
      required String? text, 
      IconData? icon, 
      required bool showLoad,
    }) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(text!),
      alignment: Alignment.bottomCenter,
      icon: Icon(icon),
      showIcon: icon != null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: showLoad,
      closeButtonShowType: CloseButtonShowType.always,
      dragToClose: true,
      closeOnClick: false,
      foregroundColor: Colors.red,
      primaryColor: Colors.red
    );
  }

  static void showSuccessSnackBar(    {
      required BuildContext context, 
      required String? text, 
      IconData? icon, 
      required bool showLoad,
    }) {
     toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(text!),
      alignment: Alignment.bottomCenter,
      icon: Icon(icon),
      showIcon: icon != null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: showLoad,
      closeButtonShowType: CloseButtonShowType.always,
      dragToClose: true,
      closeOnClick: false,
      foregroundColor: Colors.green,
      primaryColor: Colors.green
    );
  }

  static void showInfoSnackBar(    {
      required BuildContext context, 
      required String? text, 
      IconData? icon, 
      required bool showLoad,
    }) {
     toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(text!),
      alignment: Alignment.bottomCenter,
      icon: Icon(icon),
      showIcon: icon != null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: showLoad,
      closeButtonShowType: CloseButtonShowType.always,
      dragToClose: true,
      closeOnClick: false,
      foregroundColor: Colors.blue,
      primaryColor: Colors.blue      
    );
  }

  static double parseCurrency(String currency) {
    String cleanedCurrency = currency.replaceAll("Rp ", "").replaceAll(".", "");
    return double.tryParse(cleanedCurrency) ?? 0.0;
  }
}
