import 'dart:math';
import 'package:flutter/material.dart';
import '../constants.dart'; // e.g. kPrimaryColor, kFontFamily

// ----------------------------
// JSON structure for backend
// ----------------------------
/*
{
  "preferences": [
    { "id": "dessert", "name": "DESSERT" },
    { "id": "pork", "name": "PORK" },
    { "id": "halal", "name": "HALAL" },
    { "id": "gluten_free", "name": "GLUTEN FREE" },
    { "id": "vegan", "name": "VEGAN" },
    { "id": "beef", "name": "BEEF" },
    { "id": "chicken", "name": "CHICKEN" },
    { "id": "spicy", "name": "SPICY" },
    { "id": "diet", "name": "DIET" },
    { "id": "diabetes", "name": "DIABETES" },
    { "id": "hypertension", "name": "HYPER-TENSION" },
    { "id": "party", "name": "PARTY" },
    { "id": "fruit", "name": "FRUIT" },
    // etc...
  ]
}
*/

// ----------------------------
// Model for Preference
// ----------------------------
class PreferenceItem {
  final String id;
  final String name;
  bool selected;
  PreferenceItem({required this.id, required this.name, this.selected = false});
}

// ----------------------------
// Preference Config Screen
// ----------------------------
class PreferenceConfigScreen extends StatefulWidget {
  const PreferenceConfigScreen({super.key});

  @override
  State<PreferenceConfigScreen> createState() => _PreferenceConfigScreenState();
}

class _PreferenceConfigScreenState extends State<PreferenceConfigScreen> {
  // List of preferences (in real app, fetch from backend).
  final List<PreferenceItem> _preferences = [
    PreferenceItem(id: 'pork', name: 'PORK'),
    PreferenceItem(id: 'dessert', name: 'DESSERT'),
    PreferenceItem(id: 'halal', name: 'HALAL'),
    PreferenceItem(id: 'gluten_free', name: 'GLUTEN FREE'),
    PreferenceItem(id: 'vegan', name: 'VEGAN'),
    PreferenceItem(id: 'beef', name: 'BEEF'),
    PreferenceItem(id: 'chicken', name: 'CHICKEN'),
    PreferenceItem(id: 'spicy', name: 'SPICY'),
    PreferenceItem(id: 'diet', name: 'DIET'),
    PreferenceItem(id: 'diabetes', name: 'DIABETES'),
    PreferenceItem(id: 'hypertension', name: 'HYPER-TENSION'),
    PreferenceItem(id: 'party', name: 'PARTY'),
    PreferenceItem(id: 'fruit', name: 'FRUIT'),
  ];

  // We store random diameters for each preference so they don’t change on rebuild.
  final Map<String, double> _circleSizes = {};

  @override
  void initState() {
    super.initState();
    // Assign a random diameter for each preference item, e.g. between 60 and 110.
    for (var pref in _preferences) {
      _circleSizes[pref.id] = Random().nextDouble() * 50 + 60; // 60..110
    }
  }

  // Handler for tapping a circle
  void _togglePreference(PreferenceItem pref) {
    setState(() {
      pref.selected = !pref.selected;
    });
  }

  // Handler for Save button
  void _savePreferences() async {
    // Count how many are selected
    final selectedCount = _preferences.where((p) => p.selected).length;
    if (selectedCount < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please choose at least 3 preferences!',
            style: TextStyle(fontFamily: kFontFamily),
          ),
        ),
      );
      return;
    }

    // Simulate sending to backend
    final selectedIds =
        _preferences.where((p) => p.selected).map((p) => p.id).toList();
    // TODO: call your real backend API with selectedIds

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Preferences saved: ${selectedIds.join(", ")}',
          style: const TextStyle(fontFamily: kFontFamily),
        ),
      ),
    );
    Navigator.of(context).pop(); // or pop to close screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tell us your preference!',
          style: TextStyle(
            fontFamily: kFontFamily,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        backgroundColor: kPrimaryColor,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Choose at least 3 preference so we can personalise suggestion!',
                style: TextStyle(fontFamily: kFontFamily),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: _preferences
                          .map(
                            (pref) => _buildPreferenceBubble(pref),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285A17),
                  ),
                  onPressed: _savePreferences,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: kFontFamily,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreferenceBubble(PreferenceItem pref) {
    final diameter = _circleSizes[pref.id] ?? 80.0;
    final isSelected = pref.selected;

    return InkWell(
      onTap: () => _togglePreference(pref),
      borderRadius: BorderRadius.circular(diameter / 2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            pref.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kFontFamily,
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
