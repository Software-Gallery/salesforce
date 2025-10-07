import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:salesforce/config.dart';
import 'package:salesforce/l10n/app_localizations.dart';
import 'package:salesforce/provider/BarangProvider.dart';
import 'package:salesforce/styles/colors.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'navigator_item.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final barangProvider = Provider.of<BarangProvider>(context, listen: false);
        barangProvider.belanjaPopulateFromApi(); 
      } catch (e) {
        print(e.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigatorItems[currentIndex].screen,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15),
            topLeft: Radius.circular(15),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black38.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 37,
                offset: Offset(0, -12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            currentIndex: currentIndex,
            onTap: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.secondaryColor,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: AppConfig.appSize(context, .01)),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600,fontSize: AppConfig.appSize(context, .008)),
            unselectedItemColor: Colors.black,
            // items: navigatorItems.map((e) {
            //   return getNavigationBarItem(
            //       label: e.label, index: e.index, iconPath: e.iconPath);
            // }).toList(),
            items: [
              getNavigationBarItem(label: navigatorItems[0].label, index: 0, iconPath: navigatorItems[0].iconPath),
              getNavigationBarItem(label: navigatorItems[1].label, index: 1, iconPath: navigatorItems[1].iconPath),
              getNavigationBarItem(label: navigatorItems[2].label, index: 2, iconPath: navigatorItems[2].iconPath),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem getNavigationBarItem(
      {required String label, required String iconPath, required int index}) {
    Color iconColor =
        index == currentIndex ? AppColors.secondaryColor : Colors.black;
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(
        iconPath,
        color: iconColor,
        height: AppConfig.appSize(context, .018),
      ),
      
    );
  }
}
