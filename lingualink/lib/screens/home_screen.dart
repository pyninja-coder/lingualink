import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lingualink/screens/chat_detail_screen.dart'; // Import your chat detail screen here
import 'package:lingualink/screens/user_list_screen.dart'; // Import your user list screen here
import 'profile_screen.dart'; // Import your profile screen here

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchText = '';
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) { // Profile item index
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              "Lingua",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            Text(
              "Link",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    _searchText = value.toLowerCase().trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search...",
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final rooms = snapshot.data!.docs;

                return Column(
                  children: rooms.map((room) {
                    final List<String> userIds = List<String>.from(room['userIds'] ?? []);
                    final String otherUserId = userIds.firstWhere((userId) => userId != FirebaseAuth.instance.currentUser!.uid);

                    return FutureBuilder<String>(
                      future: getUserName(otherUserId),
                      builder: (context, userNameSnapshot) {
                        if (userNameSnapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (_searchText.isNotEmpty && !userNameSnapshot.data!.toLowerCase().contains(_searchText)) {
                          return SizedBox.shrink(); // Hide the ListTile if it doesn't match the search text
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('rooms').doc(room.id).collection('messages').orderBy('timestamp', descending: true).limit(1).snapshots(),
                          builder: (context, messageSnapshot) {
                            if (messageSnapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final messages = messageSnapshot.data!.docs;
                            String lastMessage = '';
                            String lastMessageTime = '';

                            if (messages.isNotEmpty) {
                              lastMessage = messages[0]['messageContent'];
                              final timestamp = messages[0]['timestamp'] as Timestamp;
                              final DateTime dateTime = timestamp.toDate();
                              lastMessageTime = DateFormat('HH:mm').format(dateTime);
                            }

                            return GestureDetector(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailPage(
                                      name: userNameSnapshot.data ?? '',
                                      recipientId: otherUserId,
                                      roomId: room.id,
                                    ),
                                  ),
                                );
                              },
                              child: ListTile(
                                leading: FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                                  builder: (context, userSnapshot) {
                                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                                      return CircleAvatar(); // Placeholder while loading
                                    }
                                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                                    final photoURL = userData['photoURL'] as String?;
                                    return CircleAvatar(
                                      backgroundImage: photoURL != null && photoURL.isNotEmpty
                                          ? Image.network(
                                              photoURL,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Error loading image: $error');
                                                return Image.asset('assets/default_profile_image.png'); // Use default profile image on error
                                              },
                                            ).image
                                          : AssetImage('assets/default_profile_image.png'), // Use default profile image if photoURL is null or empty
                                    );
                                  },
                                ),
                                title: Text(userNameSnapshot.data ?? ''),
                                subtitle: Text(lastMessage),
                                trailing: Text(
                                  lastMessageTime,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Call the _onItemTapped function when an item is tapped
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_work),
            label: "Channels",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserListScreen(),
            ),
          );
        },
        backgroundColor: Colors.green,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<String> getUserName(String userId) async {
    final DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();

    final userData = userSnapshot.data() as Map<String, dynamic>;
    return userData['displayName'];
  }
}
