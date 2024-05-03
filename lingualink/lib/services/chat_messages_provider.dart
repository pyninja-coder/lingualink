import 'package:flutter/material.dart';

class ChatMessagesProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];

  List<ChatMessage> get messages => _messages;

  void addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}

class ChatMessage {
  final String content;

  ChatMessage({required this.content});
}
