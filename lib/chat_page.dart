import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gpt_chatter/chat_message.dart';
import 'package:gpt_chatter/database_helper.dart';

const API_URL = 'https://api.openai.com/v1/chat/';

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    _messages = await DatabaseHelper.instance.getChatMessagesList();
  }

  final TextEditingController _textController = TextEditingController();
  List<ChatMessage> _messages = [];

  final Dio _dio = Dio(BaseOptions(baseUrl: API_URL));
  String apiKey = 'sk-xxx';

  Future<void> _sendMessage(String text) async {
    // 向ChatGPT API发送消息
    setState(() {
      DatabaseHelper.instance.insertChatMessage(
          ChatMessage(role: 0, content: text, isSender: true));
    });
    try {
      var data = "[{\"role\": \"user\", \"content\": \"$text\"}]";
      Response response = await _dio.post(
        'completions',
        data: {
          'messages': jsonDecode(data),
          'model': "gpt-3.5-turbo",
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
        ),
      );
      if (response.statusCode == 200) {
        setState(() {
          _messages.add(
            ChatMessage(
                role: 1,
                content: response.data['choices'][0]['message']['content'],
                isSender: false),
          );
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                ChatMessage message = _messages[index];
                IconData iconData;
                Color backgroundColor;
                CrossAxisAlignment crossAxisAlignment;

                if (message.isSender) {
                  iconData = Icons.person;
                  backgroundColor = Colors.lightBlue;
                  crossAxisAlignment = CrossAxisAlignment.start;
                } else {
                  iconData = Icons.person_outline;
                  backgroundColor = Colors.lightGreen;
                  crossAxisAlignment = CrossAxisAlignment.end;
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: crossAxisAlignment,
                    children: [
                      Icon(iconData),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          message.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      _sendMessage(_textController.text);
                      _textController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
