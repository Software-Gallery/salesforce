import 'package:flutter/material.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/styles/colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final double roundness;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final Widget? trailingWidget;
  final Function? onPressed;
  final bool isOutline;
  final bool isLoad;
  final Color? color;

  const AppButton({
    Key? key,
    required this.label,
    this.roundness = 18,
    this.fontWeight = FontWeight.bold,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.trailingWidget,
    this.onPressed,
    this.isOutline = false,
    this.isLoad = false,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      child: ElevatedButton(
        onPressed: () {
          onPressed?.call();
        },
        style: ElevatedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(roundness),
          ),
          elevation: 0,
          backgroundColor: color == null ? AppColors.primaryColor : color,
          foregroundColor: Colors.white,
          side: BorderSide(
            color: color == null ? AppColors.primaryColor : color!,
            width: 2.0,
          ),
          textStyle: TextStyle(
            fontWeight: fontWeight,
          ),
          padding: padding,
          minimumSize: const Size.fromHeight(50),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            isLoad
            ? Container(
              width: AppConfig.appSize(context, .02),
              height: AppConfig.appSize(context, .02),
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
            :
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppConfig.appSize(context, .014),
                  fontWeight: fontWeight,
                ),
              ),
            ),
            if (trailingWidget != null)
              Positioned(
                top: 0,
                right: 25,
                child: trailingWidget!,
              ),
          ],
        ),
      ),
    );
  }
}
