import 'package:flutter/material.dart';

class LanguageSelectionWidget extends StatefulWidget {
  final Function(String) onSelectLanguage;

  const LanguageSelectionWidget({Key? key, required this.onSelectLanguage}) : super(key: key);

  @override
  _LanguageSelectionWidgetState createState() => _LanguageSelectionWidgetState();
}

class _LanguageSelectionWidgetState extends State<LanguageSelectionWidget> {
  String _selectedLanguage = 'English'; // Default language

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedLanguage,
      onChanged: (newValue) {
        setState(() {
          _selectedLanguage = newValue!;
          widget.onSelectLanguage(newValue);
        });
      },
      items: <String>['English', 'Spanish', 'French'] // Add more languages as needed
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
