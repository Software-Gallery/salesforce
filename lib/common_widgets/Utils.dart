import 'package:flutter/material.dart';

class Utils {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void _show({
    required BuildContext? context,
    required String? text,
    required Color color,
    IconData? icon,
    bool showLoad = false,
  }) {
    void doShow() {
      final messenger = messengerKey.currentState ??
          (context != null ? ScaffoldMessenger.maybeOf(context) : null);
      if (messenger == null) {
        debugPrint('[Utils] SnackBar gagal tampil (messenger null): $text');
        return;
      }
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  text ?? '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => doShow());
  }

  static void showActionSnackBar({
    required BuildContext context,
    required String? text,
    IconData? icon,
    required bool showLoad,
  }) {
    _show(
      context: context,
      text: text,
      icon: icon,
      showLoad: showLoad,
      color: Colors.red.shade600,
    );
  }

  static void showSuccessSnackBar({
    required BuildContext context,
    required String? text,
    IconData? icon,
    required bool showLoad,
  }) {
    _show(
      context: context,
      text: text,
      icon: icon,
      showLoad: showLoad,
      color: Colors.green.shade600,
    );
  }

  static void showInfoSnackBar({
    required BuildContext context,
    required String? text,
    IconData? icon,
    required bool showLoad,
  }) {
    _show(
      context: context,
      text: text,
      icon: icon,
      showLoad: showLoad,
      color: Colors.blue.shade600,
    );
  }

  static double parseCurrency(String currency) {
    String cleanedCurrency = currency.replaceAll("Rp ", "").replaceAll(".", "");
    return double.tryParse(cleanedCurrency) ?? 0.0;
  }
}
