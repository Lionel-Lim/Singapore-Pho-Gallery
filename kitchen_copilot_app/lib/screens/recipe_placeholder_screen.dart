import 'package:flutter/material.dart';
import '../constants.dart';

class RecipePlaceholderScreen extends StatelessWidget {
  const RecipePlaceholderScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RECIPE', style: TextStyle(fontFamily: kFontFamily)),
        backgroundColor: kPrimaryColor,
      ),
      body: const Center(
        child: Text(
          'Recipe Screen Placeholder',
          style: TextStyle(fontSize: 18, fontFamily: kFontFamily),
        ),
      ),
    );
  }
}
