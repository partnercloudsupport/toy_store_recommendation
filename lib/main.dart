import 'package:flutter/material.dart';
import 'package:toy_store/ui/login_page.dart';
void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Toy Store Recommendation',
      theme: new ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: new LoginPage(),
    );
  }
}