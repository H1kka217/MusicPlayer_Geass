import 'package:flutter/material.dart';
import 'package:geass/songs.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home:  Songs(),
    );
  }
}

