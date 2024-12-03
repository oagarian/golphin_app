import 'package:flutter/material.dart';
import 'package:golphin_app/database/helper.dart';
import 'package:golphin_app/models/database.dart';
import 'package:golphin_app/pages/login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatDatabaseHelper dbHelper = ChatDatabaseHelper.instance;
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final loadedMessages = await dbHelper.getMessages();
    setState(() {
      messages = loadedMessages;
    });
    _scrollToEnd();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;
    final userMessage = ChatMessage(content: text, isUserMessage: true);
    await dbHelper.insertMessage(userMessage);
    _controller.clear();

    setState(() {
      messages.add(userMessage);
    });
    _scrollToEnd();

    final response = await _sendToApi(text);
    if (response != null) {
      final botMessage = ChatMessage(content: response, isUserMessage: false);
      await dbHelper.insertMessage(botMessage);

      setState(() {
        messages.add(botMessage);
      });
      _scrollToEnd();
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

    
  

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).push(_createRoute()); 
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Deseja mesmo sair?"),
          actions: [
            TextButton(
              child: const Text("Não"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Sim"),
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
            ),
          ],
        );
      },
    );
  }

  Future<String?> _sendToApi(String prompt) async {
    final url = Uri.parse('https://golphin-api.onrender.com/api');
    final prefs = await SharedPreferences.getInstance();
    final jwtToken = prefs.getString('JWT') ?? "";

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(utf8.decode(response.bodyBytes));
        return responseBody['content'];
      } else if (response.statusCode == 401) {
        _logout();
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,  // Attach the controller here
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  alignment: message.isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: message.isUserMessage ? Colors.teal[100] : Colors.teal[900],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: parseMessage(message.content),
                        style: TextStyle(
                          color: message.isUserMessage ? Colors.black : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Digite uma mensagem...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  List<TextSpan> parseMessage(String content) {
  final spans = <TextSpan>[];
  final boldPattern = RegExp(r'\*\*(.*?)\*\*');
  final italicPattern = RegExp(r'\*(.*?)\*');
  final bulletPattern = RegExp(r'^\* (.*?)$', multiLine: true);

  var lastMatchEnd = 0;

  for (final match in boldPattern.allMatches(content)) {
    if (match.start > lastMatchEnd) {
      spans.add(TextSpan(text: content.substring(lastMatchEnd, match.start)));
    }
    spans.add(TextSpan(
      text: match.group(1),
      style: const TextStyle(fontWeight: FontWeight.bold),
    ));
    lastMatchEnd = match.end;
  }
  if (lastMatchEnd < content.length) {
    content = content.substring(lastMatchEnd);
    lastMatchEnd = 0;

    for (final match in italicPattern.allMatches(content)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: content.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontStyle: FontStyle.italic),
      ));
      lastMatchEnd = match.end;
    }
  }

  if (lastMatchEnd < content.length) {
    content = content.substring(lastMatchEnd);
    lastMatchEnd = 0;

    for (final match in bulletPattern.allMatches(content)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: content.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
        text: '• ${match.group(1)}\n',
      ));
      lastMatchEnd = match.end;
    }
  }

  if (lastMatchEnd < content.length) {
    spans.add(TextSpan(text: content.substring(lastMatchEnd)));
  }

  return spans;
}
  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const Login(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    );
  } 
}
