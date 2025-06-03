// screens/EditProfileScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/TextField _editprofiile.dart'; // We'll use this if the profile image is also managed by a provider

// Assuming you have a User or Profile model, similar to Event model
// If you don't have one, you might need to create a basic one.
// import 'package:aayo/models/user_profile_model.dart'; // Example path

// For demonstration, let's assume you have a provider for the user's profile image
// If your main profile image is managed by a provider like ImageSelectionProvider, you can use it here too.
// Or, if it's a separate UserProfileProvider, import that.
// Adjust path if needed

class EditProfileScreen extends StatefulWidget {
  // You might want to pass initial user data here
  final String initialName;
  final String initialAbout;
  final String initialemail;
  final String initialmobile;

  final String initialProfileImageUrl; // For network image
  final File? initialProfileImageFile; // For local file image

  const EditProfileScreen({
    super.key,
    this.initialName = 'Tanya Hill', // Default for demonstration
    this.initialAbout =
        'We have a team but still missing a couple of people. Let\'s play together! We have a team but still missing a couple of people.', // Default
    this.initialProfileImageUrl =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D', // Example profile pic
    this.initialProfileImageFile,
    this.initialemail = "durgesh@gmail.com",  this.initialmobile="+91 9662153554", // Initial local file
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _eamilController = TextEditingController();
  final _mobileController=TextEditingController();
  File? _pickedProfileImage; // Stores the newly picked local image

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName;
    _aboutController.text = widget.initialAbout;
    _pickedProfileImage = widget.initialProfileImageFile;
    _eamilController.text=widget.initialemail;
    _mobileController.text=widget.initialmobile;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedProfileImage = File(image.path);
      });
      // Optionally, if your main profile image is managed by a provider, update it here:
      // Provider.of<ImageSelectionProvider>(context, listen: false).setImage(_pickedProfileImage);
    }
  }

  void _saveProfile() {
    // Implement save logic here
    final newName = _nameController.text;
    final newAbout = _aboutController.text;

    // You would typically send this data to a database or update a global state/provider
    // For example, if you had a UserProfileProvider:
    // Provider.of<UserProfileProvider>(context, listen: false).updateProfile(
    //   newName,
    //   newAbout,
    //   _pickedProfileImage,
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved!')),
    );

    // Navigate back to the previous screen (UserProfileList)
    Navigator.of(context).pop();
  }
  String _selectedGender = 'Female';

  final List<String> _genders = ['Male', 'Female', 'Other'];
  String _selectedCountry ='United States';

  final List<String> _countries = [
    'India',
    'United States',
    'Canada',
    'United Kingdom',
    'Australia'
  ];

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
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _pickedProfileImage != null
                        ? FileImage(_pickedProfileImage!)
                            as ImageProvider<Object>?
                        : (widget.initialProfileImageUrl.isNotEmpty
                                ? NetworkImage(widget.initialProfileImageUrl)
                                : const AssetImage(
                                    'assets/placeholder_profile.png'))
                            as ImageProvider<Object>?,
                    child: _pickedProfileImage == null &&
                            widget.initialProfileImageUrl.isEmpty
                        ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.pinkAccent,
                      radius: 20,
                      child:
                          Icon(Icons.camera_alt, color: Colors.white, size: 20),
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
              controller: _eamilController,
              hintText: 'Enter your email',
              prefixIcon: Icons.person,
            ),
            const SizedBox(height: 20),
            // Gender Dropdown
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(

                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink.shade500,width: 1)
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedGender,
                  icon: const Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  items: _genders.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: value == 'Select Gender'
                              ? Colors.black
                              : Colors.black,
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
              prefixIcon: Icons.person,
            ),
SizedBox(height: 20,),
            Container(
              height: 55,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
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
                          color: value == 'Select Country' ? Colors.black : Colors.black,
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
            const SizedBox(height: 190),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink, // Button color
                foregroundColor: Colors.white, // Text color
                padding:
                    const EdgeInsets.symmetric(horizontal: 140, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Update',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

    ],
              ),
      ),);
  }
}
