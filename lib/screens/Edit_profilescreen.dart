import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/TextField _editprofiile.dart'; // Ensure this file exists

class EditProfileScreen extends StatefulWidget {
  // Initial values are now primarily for fallback or when passed directly
  // from UserProfileList (e.g., about, mobile, which are from Firestore)
  final String initialName;
  final String initialAbout;
  final String initialEmail;
  final String initialMobile; // Updated to initialMobile

  // Assuming you might pass a local file for the profile image if it was previously picked
  final File? initialProfileImageFile;

  const EditProfileScreen({
    super.key,
    this.initialName = '',
    this.initialAbout = '',
    this.initialEmail = '',
    this.initialMobile = '', // Default empty
    this.initialProfileImageFile, required String initialmobile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController(); // Renamed from _eamilController

  File? _pickedProfileImage; // Stores the newly picked local image
  User? _currentUser; // Firebase authenticated user

  String _selectedGender = 'Female'; // Default gender, will be updated from Firestore
  final List<String> _genders = ['Male', 'Female', 'Other'];

  String _selectedCountry = 'United States'; // Default country, will be updated from Firestore
  final List<String> _countries = [
    'India',
    'United States',
    'Canada',
    'United Kingdom',
    'Australia'
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;

    // Set initial values from Firebase Auth and passed arguments
    _nameController.text = _currentUser?.displayName ?? '';
    _emailController.text = _currentUser?.email ?? '';
    _aboutController.text = widget.initialAbout; // 'about' comes from UserProfileList
    _pickedProfileImage = widget.initialProfileImageFile;

    // Fetch additional profile data (mobile, gender, country) from Firestore
    _fetchAndPopulateProfileData();
  }

  // New method to fetch and populate additional profile data from Firestore
  Future<void> _fetchAndPopulateProfileData() async {
    if (_currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _mobileController.text = data['phoneNumber'] ?? widget.initialMobile; // Use fetched or initial
          _selectedGender = data['gender'] ?? 'Female'; // Use fetched or default
          _selectedCountry = data['country'] ?? 'United States'; // Use fetched or default
          _aboutController.text = data['about'] ?? widget.initialAbout; // Also fetch about here for consistency
        });
      } else {
        // If document doesn't exist, use initial values passed or component defaults
        setState(() {
          _mobileController.text = widget.initialMobile;
          // _selectedGender and _selectedCountry already have defaults
        });
      }
    } catch (e) {
      print("Error fetching user profile data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedProfileImage = File(image.path);
      });
      // TODO: Implement image upload to Firebase Storage here.
      // After upload, update user's photoURL in FirebaseAuth:
      // String downloadUrl = await uploadImageToFirebaseStorage(_pickedProfileImage!);
      // await _currentUser!.updatePhotoURL(downloadUrl);
    }
  }

  void _saveProfile() async {
    final newName = _nameController.text.trim();
    final newAbout = _aboutController.text.trim();
    final newEmail = _emailController.text.trim();
    final newMobile = _mobileController.text.trim();
    final newGender = _selectedGender;
    final newCountry = _selectedCountry;

    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active user to save profile for.')),
      );
      return;
    }

    try {
      // 1. Update Firebase Authentication profile
      await _currentUser!.updateDisplayName(newName);
      // await _currentUser!.updateEmail(newEmail); // Be careful with email updates, often requires re-authentication.

      // 2. Update/Create user document in Firestore with additional data
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .set(
        {
          'displayName': newName,
          'email': newEmail, // Storing email in Firestore too (optional, but can be useful)
          'about': newAbout,
          'phoneNumber': newMobile,
          'gender': newGender,
          'country': newCountry,
          // 'photoURL': _currentUser!.photoURL, // You might store the photo URL here after Firebase Storage upload
        },
        SetOptions(merge: true), // Merge to update existing fields or add new ones without overwriting.
      );

      // Reload _currentUser to ensure the latest display name, photoURL are reflected
      await _currentUser!.reload();
      _currentUser = FirebaseAuth.instance.currentUser; // Get the reloaded user object

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );

      Navigator.of(context).pop(); // Navigate back to UserProfileList
    } catch (e) {
      print("Error saving profile: $e");
      String errorMessage = "Failed to save profile.";
      if (e is FirebaseAuthException) {
        errorMessage = e.message ?? errorMessage;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new_sharp)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.pink,
                    child: CircleAvatar(
                      radius: 57,
                      // Display picked local image, else Firebase photoURL, else default asset
                      backgroundImage: _pickedProfileImage != null
                          ? FileImage(_pickedProfileImage!)
                          : (_currentUser?.photoURL != null
                          ? NetworkImage(_currentUser!.photoURL!)
                          : const AssetImage('images/default_avatar.png')) as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.pinkAccent,
                      radius: 20,
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            TextfieldEditprofiile(
              controller: _nameController,
              hintText: 'Enter your name',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: _emailController,
              hintText: 'Enter your email',
              prefixIcon: Icons.email,
              readOnly: true, // Often email is read-only or requires re-auth to change
            ),
            const SizedBox(height: 20),
            // Gender Dropdown
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: Colors.pink.shade500, width: 1)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  focusColor: Colors.white,
                  value: _selectedGender,
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  items: _genders.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: _mobileController,
              hintText: 'Enter your mobile number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone, // Suggest phone keyboard
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink.shade500, width: 1),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountry,
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  items: _countries.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCountry = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 20), // Reduced space here
            TextfieldEditprofiile(
              controller: _aboutController,
              hintText: 'Tell us about yourself',
              prefixIcon: Icons.info_outline,
              maxLines: 3, // Allow multiple lines for about
            ),
            const SizedBox(height: 30), // Increased space before button
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 100, vertical: 15), // Adjusted padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Update Profile', // More descriptive text
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}