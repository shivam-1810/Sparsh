import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _name;
  String? _gender;
  DateTime? _dob;
  String? _patientLanguage;
  String? _caretakerLanguage;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  void _loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name');
      _gender = prefs.getString('gender');
      String? dobString = prefs.getString('dob');
      _dob = dobString != null ? DateTime.parse(dobString) : null;
      _patientLanguage = prefs.getString('patientLanguage');
      _caretakerLanguage = prefs.getString('caretakerLanguage');
    });
  }

  void changePLanguage(String? newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('patientLanguage', newValue!);
  }

  void changeCLanguage(String? newValue) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('caretakerLanguage', newValue!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 8, 48, 109),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg16.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(
                                'assets/images/dp.png'), // Add the path to the user's picture
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildProfileDetail('Name', _name),
                        _buildProfileDetail('Gender', _gender),
                        _buildProfileDetail('Date of Birth',
                            _dob?.toLocal().toString().split(' ')[0] ?? ''),
                        _buildLanguageSelection(
                            'Patient\'s Preferred Language', _patientLanguage,
                            (newValue) {
                          setState(() {
                            changePLanguage(newValue);
                            _patientLanguage = newValue;
                          });
                        }),
                        _buildLanguageSelection(
                            'Caretaker\'s Preferred Language',
                            _caretakerLanguage, (newValue) {
                          setState(() {
                            changeCLanguage(newValue);
                            _caretakerLanguage = newValue;
                          });
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetail(String title, String? detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Text(
            '$title : ',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              detail ?? '',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelection(
      String title, String? selectedLanguage, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(
              height: 10), // Added some spacing for better appearance
          Center(
            child: DropdownButtonFormField<String>(
              value: selectedLanguage,
              onChanged: onChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: <String>['English', 'Hindi']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
