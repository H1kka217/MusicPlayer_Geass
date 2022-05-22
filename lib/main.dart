import 'package:flutter/material.dart';
import 'package:geass/songs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Корень приложения
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home:  Songs(title: 'Geass',),
    );
  }
}

