import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:para/messages_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> originalCategories = [
    {'name': 'Help', 'image': 'assets/images/help.png'},
    {'name': 'Needs', 'image': 'assets/images/needs.png'},
    {'name': 'Feelings', 'image': 'assets/images/feelings.png'},
    {'name': 'General', 'image': 'assets/images/general.png'},
  ];

  List<Map<String, String>> translatedCategories = [];
  final translator = GoogleTranslator();
  String _patientLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadPatientLanguage();
  }

  void _loadPatientLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _patientLanguage = prefs.getString('patientLanguage') ?? 'en';
    });
    if (_patientLanguage == 'Hindi') {
      _patientLanguage = 'hi';
      _translateCategories();
    } else {
      translatedCategories = originalCategories;
    }
  }

  Future<void> _translateCategories() async {
    List<Map<String, String>> tempCategories = [];
    for (var category in originalCategories) {
      final translation =
          await translator.translate(category['name']!, to: _patientLanguage);
      tempCategories
          .add({'name': translation.text, 'image': category['image']!});
    }
    setState(() {
      translatedCategories = tempCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 8, 48, 109),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg3.jpg',
            fit: BoxFit.cover,
          ),
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: translatedCategories.isNotEmpty
                ? translatedCategories.length
                : originalCategories.length,
            itemBuilder: (context, index) {
              var category = translatedCategories.isNotEmpty
                  ? translatedCategories[index]
                  : originalCategories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MessagesPage(
                        category: originalCategories[index]['name']!,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 18, 59, 109),
                        Color.fromARGB(255, 4, 31, 61)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        category['image']!,
                        height: 80,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        category['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
