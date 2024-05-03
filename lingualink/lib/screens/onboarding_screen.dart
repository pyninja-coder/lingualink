import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:lingualink/models/user.dart' as CustomUser; // Import your custom User model with an alias
import 'package:lingualink/widgets/language_selection_widget.dart'; // Import your LanguageSelectionWidget
import 'package:lingualink/widgets/image_selection_widget.dart'; // Import your ImageSelectionWidget
import 'package:lingualink/screens/home_screen.dart'; // Import your HomeScreen
import 'package:image_picker/image_picker.dart'; // Import ImagePicker

class OnBoardingScreen extends StatefulWidget {
  final CustomUser.User user;

  const OnBoardingScreen({Key? key, required this.user}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late String _selectedLanguage;
  late String _selectedImage;

  final FirebaseAuth _auth = FirebaseAuth.instance; // Initialize FirebaseAuth
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Initialize Firestore

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.user.language;
    _selectedImage = widget.user.photoURL ?? '';
  }

  void _selectLanguage(String language) {
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _selectImage(String imageUrl) {
    setState(() {
      _selectedImage = imageUrl;
    });
  }

  Future<void> _pickImage() async {
    // Use ImagePicker to select an image from the gallery
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _selectedImage = pickedFile?.path ?? '';
    });
  }

  void _saveOnboardingData(BuildContext context) async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _firestore.collection('users').doc(currentUser.uid).update({
          'photoURL': _selectedImage,
          'language': _selectedLanguage,
        });
      }

      // Navigate to the home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      print('Error saving onboarding data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose your profile picture:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: ClipOval(
                  child: Container(
                    height: 200,
                    width: 200,
                    color: Colors.grey[300],
                    child: _selectedImage.isNotEmpty
                        ? Image.file(
                            File(_selectedImage),
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.person, size: 100, color: Colors.grey),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick an Image'),
              ),
            ),

            SizedBox(height: 20.0),

            Text(
              'Select your preferred language:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            LanguageSelectionWidget(onSelectLanguage: _selectLanguage),

            SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: () => _saveOnboardingData(context),
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
