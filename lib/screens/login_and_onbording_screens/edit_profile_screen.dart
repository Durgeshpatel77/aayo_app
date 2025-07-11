import 'dart:io'; // For File type for image picking
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'package:provider/provider.dart'; // For accessing UserProvider
import 'package:shared_preferences/shared_preferences.dart'; // For initial userId
import '../../providers/onording_login_screens_providers/user_profile_provider.dart'; // Your UserProvider
import '../../widgets/textfield _editprofiile.dart'; // Your custom TextField widget
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Text editing controllers for various profile fields
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileController = TextEditingController();

  File? _pickedProfileImage; // Stores the image picked from gallery, before it's uploaded
  String _selectedGender = 'Female'; // Default selected gender
  final List<String> _genders = ['Male', 'Female', 'Other']; // List of available genders

  String _selectedCountry = 'United States'; // Default selected country
  final List<String> _countries = [
    'India',
    'United States',
    'Canada',
    'United Kingdom',
    'Australia'
  ];

  String? _firebaseUserId; // Stores the Firebase user ID to fetch backend data

  @override
  void initState() {
    super.initState();
    _initializeProfileData(); // Call this to load user data on screen init
  }

  // _initializeProfileData: Fetches user data from the provider and populates form fields.
  // This replaces _loadUserAndPopulateFields from the previous version.
  Future<void> _initializeProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming 'userId' in SharedPreferences is the Firebase UID
    _firebaseUserId = prefs.getString('userId');

    if (_firebaseUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found. Please log in again.')),
      );
      return;
    }

    try {
      // Fetch user data using the provider. Listen: false as we are just calling a method.
      await Provider.of<FetchEditUserProvider>(context, listen: false).fetchUser(_firebaseUserId!);
      if (!mounted) return; // Check mount state after async operation

      _populateFields(); // Populate controllers and dropdowns with fetched data
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    }
  }

  // _populateFields: Fills the text controllers and sets dropdown values
  // based on the data retrieved from UserProvider.
  void _populateFields() {
    final userData = Provider.of<FetchEditUserProvider>(context, listen: false).userData;
    // Check if userData is populated before trying to access keys
    if (userData.isNotEmpty) {
      _nameController.text = userData['name'] ?? '';
      _emailController.text = userData['email'] ?? '';
      _mobileController.text = userData['mobile'] ?? '';
      _aboutController.text = userData['about'] ?? '';
      // Ensure dropdown values are within the allowed lists, otherwise default.
      _selectedGender = _genders.contains(userData['gender']) ? userData['gender'] : 'Female';
      _selectedCountry = _countries.contains(userData['country']) ? userData['country'] : 'United States';
    }
  }

  // _pickImage: Handles the image selection from th

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 70,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          lockAspectRatio: true,
          initAspectRatio: CropAspectRatioPreset.square,
          aspectRatioPresets: [CropAspectRatioPreset.square],
          hideBottomControls: true,
          showCropGrid: true,
          cropGridStrokeWidth: 2,
          cropFrameStrokeWidth: 2,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
        ),
      ],
    );

    if (croppedFile == null) return;

    // ✅ Compress the cropped image
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(
      tempDir.path,
      'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      croppedFile.path,
      targetPath,
      quality: 50,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (compressedFile == null) return;

    setState(() {
      _pickedProfileImage = File(compressedFile.path);
    });

    // 📏 Optional: Log size
    final originalSize = File(croppedFile.path).lengthSync();
    final finalSize = File(compressedFile.path).lengthSync();
    debugPrint('📸 Original size: ${(originalSize / 1024).toStringAsFixed(2)} KB');
    debugPrint('🗜️ Compressed size: ${(finalSize / 1024).toStringAsFixed(2)} KB');
  }

  // _saveProfileChanges: Orchestrates the saving process, including image upload
  // and updating user data on the backend via the UserProvider.
  void _saveProfileChanges() async {
    if (_firebaseUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing. Cannot save profile.')),
      );
      return;
    }

    final userProvider = Provider.of<FetchEditUserProvider>(context, listen: false);

    String? newProfileImageUrl; // Variable to hold the URL of the uploaded image

    // Step 1: Upload new profile image if one was picked
    if (_pickedProfileImage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Uploading image...')),
      );
      // Call the provider's method to upload the image
      newProfileImageUrl = await userProvider.uploadProfileImage(_pickedProfileImage!);
      if (newProfileImageUrl == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload new profile image.')),
        );
        return; // Stop if image upload fails
      }
    }

    // Step 2: Update local user data in the provider
    userProvider.updateUserLocal(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      mobile: _mobileController.text.trim(),
      about: _aboutController.text.trim(),
      gender: _selectedGender,
      country: _selectedCountry,
      profileImageUrl: newProfileImageUrl, // Pass the uploaded image URL to local state
    );

    // Step 3: Push all updated data (including image path) to the server
    try {
      await userProvider.updateUserOnServer(); // This will send the updated _userData map to backend
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.of(context).pop(); // Go back to the previous screen (UserProfileList)
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose all text editing controllers to prevent memory leaks
    _nameController.dispose();
    _aboutController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Consumer widget rebuilds when userData changes in UserProvider,
    // ensuring the UI always reflects the latest profile information.
    return Consumer<FetchEditUserProvider>(
      builder: (context, userProvider, child) {
        final userData = userProvider.userData; // Get the latest data from the provider
        // Determine the profile image to display
        // Prioritize the image selected by the user locally (_pickedProfileImage)
        // then the image path from the backend (userData['profile']),
        // otherwise, default to null which will trigger initial/fallback text.
        ImageProvider? avatarImage;
        if (_pickedProfileImage != null) {
          avatarImage = FileImage(_pickedProfileImage!); // Show locally picked image
        } else if (userData['profile'] != null && userData['profile'].isNotEmpty) {
          // If no local pick, use the image from the backend data
          final currentProfileImagePath = userData['profile'];
          Uri? uri = Uri.tryParse(currentProfileImagePath);
          if (uri != null && uri.scheme.isNotEmpty && uri.host.isNotEmpty) {
            avatarImage = NetworkImage(currentProfileImagePath); // Full URL
          } else {
            // Assume it's a relative path on your server
            final fullServerImageUrl = 'http://82.29.167.118:8000/$currentProfileImagePath';
            avatarImage = NetworkImage(fullServerImageUrl);
          }
        }

        // Get user name for fallback display (e.g., first letter in avatar)
        final name = userData['name'] ?? 'User';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
            centerTitle: true,
            leading: InkWell(
              onTap: () => Navigator.pop(context), // Go back when back arrow is tapped
              child: const Icon(Icons.arrow_back_ios_new),
            ),
          ),
          // Show a circular progress indicator if user data is still loading
          body: userData.isEmpty && _firebaseUserId != null // Only show loading if we are trying to fetch and data is empty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Profile picture and camera icon for picking new image
                GestureDetector(
                  onTap: _pickImage, // Call _pickImage when tapping the avatar area
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.pink, // Background for the avatar
                        child: CircleAvatar(
                          radius: 57,
                          backgroundImage: avatarImage, // Dynamically set image
                          child: avatarImage == null
                              ? Center( // Fallback if no image (show first letter of name)
                            child: Text(
                              name.isNotEmpty ? name[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                  fontSize: 40, color: Colors.white),
                            ),
                          )
                              : null, // No child needed if image is present
                        ),
                      ),
                      // Camera icon positioned at the bottom right of the avatar
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
                const SizedBox(height: 30), // Vertical space

                // Name TextField
                TextfieldEditprofiile(
                  controller: _nameController,
                  hintText: 'Enter your name',
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 20),

                // Email TextField (read-only)
                TextfieldEditprofiile(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  prefixIcon: Icons.email,
                  readOnly: true, // Email is typically not editable from profile
                ),
                const SizedBox(height: 20),

                // Gender Dropdown
                _buildDropdown(
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (val) => setState(() => _selectedGender = val!),
                  label: 'Gender',
                ),
                const SizedBox(height: 20),

                // Mobile Number TextField
                TextfieldEditprofiile(
                  controller: _mobileController,
                  hintText: 'Enter your mobile number',
                  prefixIcon: Icons.phone,
                  maxLength: 10,
                  keyboardType: TextInputType.phone, // Optimize keyboard for phone input
                ),
                const SizedBox(height: 20),

                // Country Dropdown
                _buildDropdown(
                  value: _selectedCountry,
                  items: _countries,
                  onChanged: (val) => setState(() => _selectedCountry = val!),
                  label: 'Country',
                ),
                const SizedBox(height: 20),

                // About TextField (multiline)
                TextfieldEditprofiile(
                  controller: _aboutController,
                  hintText: 'Tell us about yourself',
                  prefixIcon: Icons.info_outline,
                  maxLines: 3, // Allows multiple lines of text
                  maxLength: 100,
                ),
                const SizedBox(height: 30),

                // Update Profile Button
                ElevatedButton(
                  onPressed: _saveProfileChanges, // Call the centralized save logic
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink, // Pink button background
                    foregroundColor: Colors.white, // White text color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget to build a customizable dropdown.
  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String label,
  }) {
    return Container(
      height: 55, // Fixed height for consistency
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: Colors.pink.shade500, width: 1), // Pink border
      ),
      child: DropdownButtonHideUnderline( // Hides the default underline of DropdownButton
        child: DropdownButton<String>(
          value: value,
          icon: const Icon(Icons.arrow_drop_down), // Dropdown arrow icon
          isExpanded: true, // Make dropdown take full width
          items: items // Map strings to DropdownMenuItems
              .map((String item) =>
              DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged, // Callback when an item is selected
        ),
      ),
    );
  }
}