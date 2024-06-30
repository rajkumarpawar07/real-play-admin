import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:realplayadmin/Constraints/constraints.dart';
import 'package:realplayadmin/screens/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCoHiJJAWx1ThKZyfv1H5h0UMYn6HuBG68",
          appId: '1:160171488968:android:dfeed0442ff7873b0bd7fd',
          messagingSenderId: '160171488968',
          projectId: 'real-play-app',
          storageBucket: "real-play-app.appspot.com"));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        theme: ThemeData(
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            backgroundColor: backgroundColor,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const Splash_Screen());
  }
}
