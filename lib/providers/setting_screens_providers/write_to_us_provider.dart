import 'package:flutter/material.dart';

class WriteToUsProvider with ChangeNotifier {
  String? messageType;
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  void setMessageType(String? type) {
    messageType = type;
    notifyListeners();
  }

  bool validateForm(GlobalKey<FormState> formKey) {
    return formKey.currentState?.validate() ?? false;
  }

  void clearForm() {
    nameController.clear();
    emailController.clear();
    subjectController.clear();
    messageController.clear();
    messageType = null;
    notifyListeners();
  }

  void sendMessage(BuildContext context, GlobalKey<FormState> formKey) {
    if (validateForm(formKey)) {
      // Handle sending logic here (API call, etc.)
      print('Message Type: $messageType');
      print('Name: ${nameController.text}');
      print('Email: ${emailController.text}');
      print('Subject: ${subjectController.text}');
      print('Message: ${messageController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully!')),
      );

      clearForm();
    }
  }
}
