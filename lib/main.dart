import 'package:camera/camera.dart';
import 'package:findogo/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<CameraDescription> cameras;

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FINDOGgO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}


