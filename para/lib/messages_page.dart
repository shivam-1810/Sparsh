import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';

class MessagesPage extends StatelessWidget {
  final String category;
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
      {'text': 'I am angry.', 'image': 'assets/images/angry.png'}
    ],
    'General': [
      {'text': 'Hello.', 'image': 'assets/images/hello.png'},
      {'text': 'Goodbye.', 'image': 'assets/images/goodbye.jpg'},
      {'text': 'Thank you.', 'image': 'assets/images/thankyou.png'}
    ]
  };

  MessagesPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final messages = categoryMessages[category] ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          category,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[900],
      ),
      body: ListView.builder(
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
                color: Colors.grey[850],
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
                                onPressed: () {},
                                icon: const Icon(Icons.volume_up),
                                label: const Text('Speak'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Code to send the message
                                },
                                icon: const Icon(Icons.send),
                                label: const Text('Send'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 45),
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
    );
  }
}
