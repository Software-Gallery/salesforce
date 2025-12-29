import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/services/auth_services.dart';
import 'package:upgrader/upgrader.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(MyApp());
}
