import 'package:employee_management/pages/admin_dashboard.dart';
import 'package:employee_management/pages/user_dashboard.dart';
import 'package:employee_management/services/auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  String? err;

  MainApp({super.key, this.err});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _auth = AuthServices();
  String user = "false";

  @override
  void initState() {
    super.initState();
    _auth.isUserLoggedIn(context).then((value) {
      if ((value["message"] as String).isNotEmpty) {
        widget.err = value["message"];
      }
      setState(() {
        user = value["role"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: user == "false"
          ? LoginWidget(
              errMessage: widget.err,
            )
          : user == "admin"
              ? admin_dashboard()
              : UserDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
