// screens/WriteToUsScreen.dart
import 'package:flutter/material.dart';

class WriteToUsScreen extends StatefulWidget {
  const WriteToUsScreen({super.key});

  @override
  State<WriteToUsScreen> createState() => _WriteToUsScreenState();
}

class _WriteToUsScreenState extends State<WriteToUsScreen> {
  final _formKey = GlobalKey<FormState>(); // Key for form validation
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String? _selectedMessageType; // State for the dropdown

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with sending message
      // In a real app, you would send this data to an API, email service, etc.
      print('Message Type: $_selectedMessageType');
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Subject: ${_subjectController.text}');
      print('Message: ${_messageController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully!')),
      );

      // Optionally clear fields or navigate back
      _nameController.clear();
      _emailController.clear();
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedMessageType = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write to Us'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor:Colors.white, // Match app bar background
        foregroundColor: Colors.black, // White text for title and back button
        elevation: 0, // No shadow
        leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back_ios_new_sharp)),

      ),
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey, // Assign the form key
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Message Type Dropdown
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pink.shade400,width: 1)
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedMessageType,
                  hint: const Text('Select message type',
                      style: TextStyle(color: Colors.black)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  dropdownColor: Colors.white, // Dark background for dropdown items
                  style: const TextStyle(
                      color: Colors.black), // Text color for selected item
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  items: <String>['Feedback', 'Support', 'General Inquiry']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(
                              color:
                                  Colors.black)), // Text color for list items
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedMessageType = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a message type';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                hintText: 'Enter your name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Email Field
              const SizedBox(height: 8),
              _buildTextField(
                controller: _emailController,
                hintText: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Subject Field
              const SizedBox(height: 8),
              _buildTextField(
                controller: _subjectController,
                hintText: 'Enter subject',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Message Field
              const SizedBox(height: 8),
              _buildTextField(
                controller: _messageController,
                hintText: 'Write your message here...',
                maxLines: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              // Send Message Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _sendMessage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Send Message',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build consistent labels

  // Helper method to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      // Use TextFormField for validation
      controller: controller,
      style: const TextStyle(color: Colors.black87),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.black),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(width: 1,color: Colors.pink.shade400)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(width: 1,color: Colors.pink.shade400)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(width: 1,color: Colors.pink.shade400)),

        errorStyle: const TextStyle(
            color: Colors.redAccent), // Style for validation errors
      ),
      validator: validator,
    );
  }
}
