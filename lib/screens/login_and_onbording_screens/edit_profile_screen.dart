import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/TextField _editprofiile.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  File? _pickedProfileImage;
  String _selectedGender = 'Female';
  final List<String> _genders = ['Male', 'Female', 'Other'];

  String _selectedCountry = 'United States';
  final List<String> _countries = [
    'India',
    'United States',
    'Canada',
    'United Kingdom',
    'Australia'
  ];

  String? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserAndPopulateFields();
  }

  Future<void> _loadUserAndPopulateFields() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');

    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found.')),
      );
      return;
    }

    try {
      await Provider.of<UserProvider>(context, listen: false)
          .fetchUser(_userId!);
      _populateFields();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  void _populateFields() {
    final data = Provider.of<UserProvider>(context, listen: false).userData;
    _nameController.text = data['name'] ?? '';
    _emailController.text = data['email'] ?? '';
    _mobileController.text = data['mobile'] ?? '';
    _aboutController.text = data['profile'] ?? '';
    _selectedGender = data['gender'] ?? 'Female';
    _selectedCountry = data['country'] ?? 'United States';
  }

  Future<void> _pickImage() async {
    final XFile? image =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedProfileImage = File(image.path);
      });
    }
  }

  void _saveProfile() async {
    if (_userId == null) return;

    final provider = Provider.of<UserProvider>(context, listen: false);
    provider.updateUserLocal(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      about: _aboutController.text.trim(),
      gender: _selectedGender,
      country: _selectedCountry,
    );

    try {
      await provider.updateUserOnServer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
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

  @override
  Widget build(BuildContext context) {
    final userData = Provider.of<UserProvider>(context).userData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      body: userData.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
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
                      backgroundImage: _pickedProfileImage != null
                          ? FileImage(_pickedProfileImage!)
                          : const NetworkImage("https://cdn.pixabay.com/photo/2017/11/02/09/16/christmas-2910468_1280.jpg")
                      as ImageProvider,
                    ),
                  ),
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Colors.pinkAccent,
                      radius: 20,
                      child: Icon(Icons.camera_alt,
                          color: Colors.white, size: 20),
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
              readOnly: true,
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              value: _selectedGender,
              items: _genders,
              onChanged: (val) => setState(() => _selectedGender = val!),
              label: 'Gender',
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: _mobileController,
              hintText: 'Enter your mobile number',
              prefixIcon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildDropdown(
              value: _selectedCountry,
              items: _countries,
              onChanged: (val) => setState(() => _selectedCountry = val!),
              label: 'Country',
            ),
            const SizedBox(height: 20),
            TextfieldEditprofiile(
              controller: _aboutController,
              hintText: 'Tell us about yourself',
              prefixIcon: Icons.info_outline,
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Update Profile',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String label,
  }) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.pink.shade500, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down),
          isExpanded: true,
          items: items
              .map((String item) =>
              DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
