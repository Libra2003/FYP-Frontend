import 'package:flutter/material.dart';
import 'package:flutter_rag_app/api.dart'; // Import the api.dart file
import 'splash_screen.dart'; // Import your splash_screen.dart file
import 'dart:async'; // Add this line

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Informator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: SplashScreen(), // Start with the SplashScreen
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({
          'text': _controller.text,
          'isUser': true,
        });
      });
      _scrollToBottom();
      print('Sending question to API: ${_controller.text}');
      _sendQuestionToApi(_controller.text);
      _controller.clear();
    }
  }

  Future<void> _sendQuestionToApi(String question) async {
    final response = await sendQuestionToApi(question);
    _respondToMessage(response['result'], response['source_documents']);
  }

  void _respondToMessage(String answer, List<String> sources) {
    setState(() {
      _messages.add({
        'text': '',
        'isUser': false,
        'isTyping': true, // Flag to show typing animation
      });
    });

    _streamResponse(answer, sources);
  }

  void _streamResponse(String answer, List<String> sources) {
    String displayedText = '';
    int i = 0;
    Timer.periodic(const Duration(milliseconds: 50), (Timer timer) {
      if (i < answer.length) {
        setState(() {
          displayedText += answer[i];
          _messages.last['text'] = displayedText;
        });
        _scrollToBottom();
        i++;
      } else {
        displayedText +=
            '\n\n--------------------------------------\n\nSources:\n';
        int j = 0;
        Timer.periodic(const Duration(milliseconds: 50), (Timer sourceTimer) {
          if (j < sources.length) {
            setState(() {
              displayedText += '- ${sources[j]}\n';
              _messages.last['text'] = displayedText;
            });
            _scrollToBottom();
            j++;
          } else {
            setState(() {
              _messages.last['isTyping'] = false; // Remove typing indicator
            });
            _scrollToBottom();
            sourceTimer.cancel();
          }
        });
        timer.cancel();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Center(
          child: Text(
            "Informator",
            style: TextStyle(
              color: Colors.white, // Change the color of the font
              fontSize: 24.0, // Adjust font size as needed
              fontWeight: FontWeight.bold, // Adjust font weight as needed
            ),
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: _messages[index]['isUser']
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            color: _messages[index]['isUser']
                                ? Colors.teal
                                : Colors.lightGreenAccent[100],
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _messages[index]['text'],
                            style: TextStyle(
                              fontSize: 16.0, // Increase font size
                              fontWeight:
                                  FontWeight.w600, // Make the font a bit fatter
                              color: _messages[index]['isUser']
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (value) =>
                        _sendMessage(), // Handle Enter key press
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: Colors.teal,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
