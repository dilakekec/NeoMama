import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';



class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> messages = [];
  bool isTyping = false;
  String aiTyping = "AI is typing...";
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    loadMessages();
  }
  Future<void> loadMessages() async {
    prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('chat_messages') ?? [];
      setState(() {
        messages.addAll(stored.map((e) => Map<String, String>.from(jsonDecode(e))));
      });
    }

  Future<void> saveMessages() async {
    final encoded = messages.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('chat_messages', encoded);
  }
  
  Future<void> sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;
    
    setState(() {
      messages.add({'sender': 'user', 'message': message});
      isTyping = true;
      aiTyping = "AI is typing...";
    });
    _controller.clear();
    await saveMessages();

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.36/api/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] ?? "No reply from AI";
        await _typeAiMessage(reply);
      } else {
        await _typeAiMessage('Error ${response.statusCode}');
      }
    } catch (e) {
      await _typeAiMessage('Connection Error');
    }

    setState(() => isTyping = false);
    await saveMessages();
  }

  Future<void> _typeAiMessage(String fullText) async {
    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      setState(() => aiTyping = fullText.substring(0, i + 1));
    }
    messages.add({'sender': 'ai', 'message': aiTyping});
    aiTyping = '';
  }
  
  Widget _buildBubble(Map<String, String> msg) {
    final isUser = msg['sender'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isUser ? Colors.pink[100] : Colors.purple[100],
          borderRadius: BorderRadius.only(  
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 0),
            bottomRight: Radius.circular(isUser ? 0 : 16),
          ),
        ),
        child: Text(msg['message']!, style: const TextStyle(fontSize: 15)),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: const Text('NeoMama AI Chat'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(  
              reverse: false,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: messages.length + (isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length && isTyping) {
                  return _buildBubble({'sender': 'ai', 'message': aiTyping});
                }
                return _buildBubble(messages[index]);
              },
            ),
          ),
          const Divider(height: 1),
          Container(  
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: Colors.white,
            child: SafeArea(  
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type your message',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.pink),
                    onPressed: isTyping ? null : sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}