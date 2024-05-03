import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_detail_screen.dart'; // Import your chat detail screen here

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final String otherUserId = userData['uid'];

              // Exclude the logged-in user from the list
              if (otherUserId == FirebaseAuth.instance.currentUser!.uid) {
                return SizedBox.shrink(); // Return an empty SizedBox to exclude from the list
              }

              // Generate a unique room ID
              String roomId = generateRoomId(
                  FirebaseAuth.instance.currentUser!.uid, otherUserId);

              return GestureDetector(
                onTap: () async {
                  // Navigate to the chat detail page when a user is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatDetailPage(
                        name: userData['displayName'] ?? '',
                        recipientId: userData['uid'],
                        roomId: roomId,
                      ),
                    ),
                  );
                },
                child: UserListItem(
                  name: userData['displayName'] ?? '',
                  messageText: '', // Add empty message text for now
                  time: '', // Add empty time for now
                  isMessageRead: false, // Set message read status
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final String name;
  final String messageText;
  final String time;
  final bool isMessageRead;

  const UserListItem({
    required this.name,
    required this.messageText,
    required this.time,
    required this.isMessageRead,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(Icons.account_circle),
      ),
      title: Text(name),
      subtitle: Text(messageText),
      trailing: Text(time),
    );
  }
}

String generateRoomId(String userId1, String userId2) {
  List<String> sortedIds = [userId1, userId2]..sort();
  return '${sortedIds[0]}_${sortedIds[1]}';
}
