import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  bool isReading = false;

  @override
  void initState() {
    super.initState();
    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.loadPreferences().then((_) {
      newsProvider.fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final newsProvider = Provider.of<NewsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'News',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 8, 48, 109),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              newsProvider.fetchNews();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg13.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isReading = true;
                        });
                        await newsProvider.speakAllHeadlines();
                        setState(() {
                          isReading = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 8, 48, 109),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 20.0),
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Read All Headlines Aloud'),
                    ),
                    const SizedBox(height: 5),
                    if (isReading)
                      ElevatedButton(
                        onPressed: () {
                          newsProvider.stopSpeaking();
                          setState(() {
                            isReading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 109, 8, 48),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 20.0),
                          textStyle: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        child: const Text('Stop'),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: newsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: newsProvider.newsList.length,
                        itemBuilder: (context, index) {
                          final newsItem = newsProvider.newsList[index];
                          return Card(
                            margin: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color.fromARGB(255, 57, 28, 95),
                                    Color.fromARGB(255, 34, 41, 107),
                                    Color.fromARGB(255, 57, 28, 95),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      newsItem['title'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NewsProvider with ChangeNotifier {
  List<dynamic> newsList = [];
  bool isLoading = true;
  FlutterTts flutterTts = FlutterTts();
  bool isEnglish = true;
  bool _isReading = false;
  int _currentIndex = 0;

  NewsProvider() {
    loadPreferences().then((_) => fetchNews());
  }

  Future<void> loadPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? language = prefs.getString('patientLanguage');
    isEnglish = language == null || language != 'Hindi';
    notifyListeners();
  }

  Future<void> fetchNews() async {
    isLoading = true;
    notifyListeners();

    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=in&apiKey=3474f0fc1afa41c6bd5435e73aa506c6'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      newsList = data['articles'];
      if (!isEnglish) {
        _translateNewsOneByOne();
      }
    } else {
      newsList = [];
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> _translateNewsOneByOne() async {
    for (var newsItem in newsList) {
      await _translateNewsItem(newsItem);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> _translateNewsItem(Map<String, dynamic> newsItem) async {
    final response = await http.get(Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=hi&dt=t&q=${Uri.encodeComponent(newsItem['title'])}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      newsItem['title'] = data[0][0][0];
    }
  }

  Future<void> speakAllHeadlines() async {
    _isReading = true;
    await flutterTts.setLanguage(isEnglish ? 'en-US' : 'hi-IN');

    flutterTts.setCompletionHandler(() async {
      if (_isReading && _currentIndex < newsList.length) {
        await flutterTts.speak(newsList[_currentIndex++]['title']);
      }
    });

    _currentIndex = 0;
    if (newsList.isNotEmpty) {
      await flutterTts.speak(newsList[_currentIndex++]['title']);
    }

    while (_isReading && _currentIndex < newsList.length) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _isReading = false;
  }

  void stopSpeaking() async {
    _isReading = false;
    await flutterTts.stop();
  }
}
