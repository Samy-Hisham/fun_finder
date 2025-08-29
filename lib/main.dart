import 'package:flutter/material.dart';
import 'package:fun_finder/views/home_view.dart';
import 'package:showcaseview/showcaseview.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(builder: (context) => MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeView(),
    ));
  }
}