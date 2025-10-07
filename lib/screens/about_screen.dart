import 'package:expansion_tile_group/expansion_tile_group.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:salesforce/common_widgets/app_text.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/styles/colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Widget barangGrid = Center(child: Text('Belum ada Help'),);
  bool bestDealSlideLoad = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white), 
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        title: AppText(
          text: AppLocalizations.of(context)!.account_about_title,
          fontWeight: FontWeight.bold,
          fontSize: AppConfig.appSize(context, .016),
          color: Colors.white,
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            splashScreenIcon(context),
            welcomeTextWidget(context),
            subtextWidget(context),
          ],
        ), 
      ),
    );
  }

  Widget splashScreenIcon(BuildContext context) {
    String iconPath = "assets/images/logo.png";
    return Image.asset(
      iconPath,
      width: MediaQuery.of(context).size.width / 3,
    );
  }

  Widget welcomeTextWidget(BuildContext context) {
    return Column(
      children: [
        AppText(
          text: "Happy Shop",
          fontSize: AppConfig.appSize(context, .02),
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ],
    );
  }

  Widget subtextWidget(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return AppText(
            text: 'Error loading version',
            fontSize: AppConfig.appSize(context, .012),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          );
        } else {
          final version = snapshot.data?.version ?? "Unknown version";
          return AppText(
            text: "Ver. $version",
            fontSize: AppConfig.appSize(context, .012),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGrey,
          );
        }
      },
    );
  }
}
