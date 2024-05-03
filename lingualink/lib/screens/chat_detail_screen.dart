import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDetailPage extends StatefulWidget {
  final String name;
  final String recipientId;
  final String roomId;

  ChatDetailPage({
    required this.name,
    required this.recipientId,
    required this.roomId,
  });

  @override
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  late String _currentUserId;
  late CollectionReference _messagesRef;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _messagesRef = FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).collection('messages');

    // Sync messages when the app is resumed
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _syncMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String name = widget.name;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        flexibleSpace: SafeArea(
          child: Container(
            padding: EdgeInsets.only(right: 16),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.black),
                ),
                SizedBox(width: 2),
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      "<https://randomuser.me/api/portraits/men/5.jpg>"),
                  maxRadius: 20,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Online",
                        style:
                            TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.settings, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Container(
                padding: EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                child: Align(
                  alignment: message.senderId == _currentUserId ? Alignment.topRight : Alignment.topLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: message.senderId == _currentUserId ? Colors.blue[200] : Colors.grey.shade200,
                    ),
                    padding: EdgeInsets.all(16),
                    child: Text(message.messageContent, style: TextStyle(fontSize: 15)),
                  ),
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
              height: 60,
              width: double.infinity,
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        color: Colors.lightBlue,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Write message...",
                        hintStyle: TextStyle(color: Colors.black54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  FloatingActionButton(
                    onPressed: _sendMessage,
                    child: Icon(Icons.send, color: Colors.white, size: 18),
                    backgroundColor: Colors.blue,
                    elevation: 0,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final newMessage = ChatMessage(
        senderId: _currentUserId,
        receiverId: widget.recipientId,
        messageContent: messageText,
        timestamp: DateTime.now(),
      );

      // Ensure the room document exists before adding the message
      FirebaseFirestore.instance.collection('rooms').doc(widget.roomId).set({
        'userIds': [_currentUserId, widget.recipientId], // Add user IDs to room
      }).then((_) {
        _messagesRef.add(newMessage.toMap()).then((value) {
          setState(() {
            _messages.add(newMessage);
          });
          _messageController.clear();
        }).catchError((error) {
          print("Failed to send message: $error");
        });
      }).catchError((error) {
        print("Failed to create room document: $error");
      });
    }
  }

  void _syncMessages() {
    _messagesRef.orderBy('timestamp').snapshots().listen((querySnapshot) {
      setState(() {
        _messages = querySnapshot.docs.map((doc) => ChatMessage.fromFirestore(doc)).toList();
      });
    });
  }
}

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String messageContent;
  final DateTime timestamp;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.messageContent,
    required this.timestamp,
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
    );
  }
}
