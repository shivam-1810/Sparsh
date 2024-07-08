// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:para/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsPage extends StatefulWidget {
  const UserDetailsPage({super.key});

  @override
  _UserDetailsPageState createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  String? _gender;
  DateTime? _dob;
  String? _patientLanguage;
  String? _caretakerLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildNameScreen(),
          _buildPatientLanguageScreen(),
          _buildCaretakerLanguageScreen(),
        ],
      ),
    );
  }

  Widget _buildNameScreen() {
    return _buildScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Enter Patient\'s Name',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _nameController,
            hintText: 'Name',
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Gender',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 10),
          _buildDropdown(
            value: _gender,
            items: ['Male', 'Female', 'Other'],
            onChanged: (String? newValue) {
              setState(() {
                _gender = newValue;
              });
            },
          ),
          const SizedBox(height: 20),
          const Text(
            'Enter Date of Birth',
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _dob = picked;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.purple[900],
              backgroundColor: Colors.white,
            ),
            child: Text(
              _dob == null
                  ? 'Select Date'
                  : _dob!.toLocal().toString().split(' ')[0],
            ),
          ),
        ],
      ),
      buttonText: 'Next',
      onButtonPressed: () {
        if (_nameController.text.isNotEmpty &&
            _gender != null &&
            _dob != null) {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
        } else {
          _showErrorDialog('Please fill all the fields');
        }
      },
    );
  }

  Widget _buildPatientLanguageScreen() {
    return _buildScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Patient\'s Preferred Language',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            value: _patientLanguage,
            items: ['English', 'Hindi'],
            onChanged: (String? newValue) {
              setState(() {
                _patientLanguage = newValue;
              });
            },
          ),
        ],
      ),
      buttonText: 'Next',
      onButtonPressed: () {
        if (_patientLanguage != null) {
          _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeIn);
        } else {
          _showErrorDialog('Please select a language');
        }
      },
    );
  }

  Widget _buildCaretakerLanguageScreen() {
    return _buildScreen(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Caretaker\'s Preferred Language',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            value: _caretakerLanguage,
            items: ['English', 'Hindi'],
            onChanged: (String? newValue) {
              setState(() {
                _caretakerLanguage = newValue;
              });
            },
          ),
        ],
      ),
      buttonText: 'Get Started',
      onButtonPressed: () async {
        if (_caretakerLanguage != null) {
          await _saveUserDetails();
          Navigator.pushReplacement(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(
              builder: (context) => const MainScreen(),
            ),
          );
        } else {
          _showErrorDialog('Please select a language');
        }
      },
    );
  }

  Future<void> _saveUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('gender', _gender!);
    await prefs.setString('dob', _dob!.toIso8601String());
    await prefs.setString('patientLanguage', _patientLanguage!);
    await prefs.setString('caretakerLanguage', _caretakerLanguage!);
  }

  Widget _buildScreen({
    required Widget child,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg17.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 50), // for spacing at the top
            Expanded(child: child),
            ElevatedButton(
              onPressed: onButtonPressed,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.purple[900],
                backgroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
  }) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButton<String>(
      value: value,
      borderRadius: BorderRadius.circular(15),
      dropdownColor: Colors.purple[900],
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            ElevatedButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
