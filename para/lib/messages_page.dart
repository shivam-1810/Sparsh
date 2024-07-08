// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:background_sms/background_sms.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class MessagesPage extends StatefulWidget {
  final String category;

  const MessagesPage({super.key, required this.category});

  @override
  // ignore: library_private_types_in_public_api
  _MessagesPageState createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final FlutterTts flutterTts = FlutterTts();
  final translator = GoogleTranslator();
  String _patientLanguage = 'en';

  final Map<String, List<Map<String, String>>> categoryMessages = {
    'Help': [
      {'text': 'I need help!', 'image': 'assets/images/needhelp.png'},
      {'text': 'Call a doctor!', 'image': 'assets/images/calldoctor.png'},
      {'text': 'I am in pain!', 'image': 'assets/images/pain.png'}
    ],
    'Needs': [
      {'text': 'I need water.', 'image': 'assets/images/needwater.png'},
      {'text': 'I am hungry.', 'image': 'assets/images/needfood.png'},
      {
        'text': 'I need to use the washroom.',
        'image': 'assets/images/restroom.png'
      }
    ],
    'Feelings': [
      {'text': 'I am happy.', 'image': 'assets/images/happy.png'},
      {'text': 'I am sad.', 'image': 'assets/images/sad.png'},
      {'text': 'I am annoyed.', 'image': 'assets/images/angry.png'}
    ],
    'General': [
      {'text': 'Hello.', 'image': 'assets/images/hello.png'},
      {'text': 'Goodbye.', 'image': 'assets/images/goodbye.jpg'},
      {'text': 'Thank you.', 'image': 'assets/images/thankyou.png'}
    ]
  };

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
      _translateMessagesToHindi();
    }
  }

  Future<void> _translateMessagesToHindi() async {
    for (var category in categoryMessages.keys) {
      for (var message in categoryMessages[category]!) {
        var translation =
            await translator.translate(message['text']!, to: 'hi');
        setState(() {
          message['text'] = translation.text;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = categoryMessages[widget.category] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 8, 48, 109),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/bg6.jpg',
            fit: BoxFit.cover,
          ),
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return ExpandableNotifier(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: const Color.fromARGB(255, 30, 56, 136),
                    child: Column(
                      children: <Widget>[
                        ScrollOnExpand(
                          scrollOnExpand: true,
                          scrollOnCollapse: false,
                          child: ExpandablePanel(
                            theme: const ExpandableThemeData(
                              headerAlignment:
                                  ExpandablePanelHeaderAlignment.center,
                              tapBodyToExpand: true,
                              tapBodyToCollapse: true,
                              hasIcon: true,
                              iconColor: Colors.white,
                            ),
                            header: Padding(
                              padding: const EdgeInsets.all(13),
                              child: Row(
                                children: [
                                  Image.asset(
                                    message['image']!,
                                    width: 40,
                                    height: 40,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      message['text']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            collapsed: Container(),
                            expanded: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      translateAndSpeakMessage(
                                          context, message['text']!);
                                    },
                                    icon: const Icon(Icons.volume_up),
                                    label: const Text('Speak'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      minimumSize:
                                          const Size(double.infinity, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      translateAndSendSMS(
                                          context, message['text']!);
                                    },
                                    icon: const Icon(Icons.send),
                                    label: const Text('Send'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      minimumSize:
                                          const Size(double.infinity, 45),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void translateAndSpeakMessage(BuildContext context, String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? caretakerLanguage = prefs.getString('caretakerLanguage') ?? 'en';
    if (caretakerLanguage == 'English') {
      caretakerLanguage = 'en';
    } else {
      caretakerLanguage = 'hi';
    }

    var translation =
        await translator.translate(message, to: caretakerLanguage);
    await flutterTts.setLanguage(caretakerLanguage == 'hi' ? 'hi-IN' : 'en-US');
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(translation.text);
  }

  void translateAndSendSMS(BuildContext context, String message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? caretakerLanguage = prefs.getString('caretakerLanguage') ?? 'en';
    if (caretakerLanguage == 'English') {
      caretakerLanguage = 'en';
    } else {
      caretakerLanguage = 'hi';
    }

    var translation =
        await translator.translate(message, to: caretakerLanguage);
    String? phoneNumber = prefs.getString('phoneNumber');

    if (phoneNumber == null) {
      // Ask for phone number if not set
      showDialog(
        context: context,
        builder: (BuildContext context) {
          TextEditingController phoneController = TextEditingController();
          return AlertDialog(
            title: const Text('Enter Phone Number'),
            content: TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration:
                  const InputDecoration(hintText: 'Recipient Phone Number'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String inputNumber = phoneController.text;
                  if (inputNumber.isNotEmpty) {
                    await prefs.setString('phoneNumber', inputNumber);
                    sendTranslatedSMS(context, translation.text, inputNumber);
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      sendTranslatedSMS(context, translation.text, phoneNumber);
    }
  }

  void sendTranslatedSMS(
      BuildContext context, String message, String phoneNumber) async {
    if (await Permission.sms.request().isGranted) {
      final SmsStatus result = await BackgroundSms.sendMessage(
        phoneNumber: phoneNumber,
        message: message,
        simSlot: 2,
      );
      String feedbackMessage;
      if (result == SmsStatus.sent) {
        feedbackMessage = 'SMS sent successfully';
      } else {
        feedbackMessage = 'Failed to send SMS';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            feedbackMessage,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
