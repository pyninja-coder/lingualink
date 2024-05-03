import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String messageContent;
  final DateTime timestamp;
  final String? translatedMessage; // Add translated message field

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.messageContent,
    required this.timestamp,
    this.translatedMessage, // Initialize translated message
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'messageContent': messageContent,
      'timestamp': timestamp,
    };
  }

  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      messageContent: data['messageContent'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      translatedMessage: data['translatedMessage'], // Assign translated message
    );
  }
}
