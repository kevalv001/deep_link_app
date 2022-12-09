import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_storage/get_storage.dart';

import 'login_page.dart';

ColorScheme defaultColorScheme = const ColorScheme(
  primary: Color(0xffBB86FC),
  secondary: Color(0xff03DAC6),
  surface: Color(0xff181818),
  background: Color(0xff121212),
  error: Color(0xffCF6679),
  onPrimary: Color(0xff000000),
  onSecondary: Color(0xff000000),
  onSurface: Color(0xffffffff),
  onBackground: Color(0xffffffff),
  onError: Color(0xff000000),
  brightness: Brightness.dark,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  runApp(
    MaterialApp(
      title: 'Dynamic Links Example',
      debugShowCheckedModeBanner: false,
      home: LoginPage(title: 'title'),
      theme: ThemeData(
        colorScheme: defaultColorScheme,
        primarySwatch: Colors.blue,
      ),
      builder: EasyLoading.init(),
    ),
  );
}
