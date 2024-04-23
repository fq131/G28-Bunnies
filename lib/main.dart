import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:yumify/screen/splash.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyB5mZvPDyhnBl4PZREJ-xQJKdlX3mf7oMw",
        appId: "1:618335465507:android:c8545400b5cedbecd80196",
        messagingSenderId: "618335465507",
        projectId: "yumify-7e3de",
        storageBucket: "yumify-7e3de.appspot.com"),
  );
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Future.delayed(
    const Duration(microseconds: 1),
  );
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Group Practical Assignment',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Color.fromARGB(255, 255, 255, 255)),
      home: SplashScreen(),
    );
  }
}
