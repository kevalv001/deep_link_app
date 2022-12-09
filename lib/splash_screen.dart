import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import 'dashboard_screen.dart';
import 'login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final box = GetStorage();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _setInitRoute();
    });
  }


  _setInitRoute() {
    String? uuid = box.read('uuid');
    print(uuid);
    if (uuid != null && uuid != "") {
      Future.delayed(const Duration(seconds: 1)).then(
          (value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return const DashboardScreen(
                    firstName: "",
                  );
                },
              ), (route) => false));
    } else {
      Future.delayed(const Duration(seconds: 1)).then(
          (value) => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return const LoginPage(
                    title: "Login",
                  );
                },
              ), (route) => false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FlutterLogo(size: 200),
    );
  }
}
