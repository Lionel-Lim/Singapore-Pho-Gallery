import 'package:flutter/material.dart';
import 'constants.dart';
import 'screens/home_screen.dart';

void main() => runApp(const CommunityApp());

class CommunityApp extends StatelessWidget {
  const CommunityApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitchen Copilot',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: kPrimaryColor,
        fontFamily: kFontFamily,
      ),
      home: const HomeScreen(),
    );
  }
}
