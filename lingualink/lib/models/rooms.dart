import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String roomId;
  final List<String> userIds;

  Room({
    required this.roomId,
    required this.userIds,
  });

  factory Room.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final List<String> userIds = List<String>.from(data['userIds'] ?? []);
    return Room(
      roomId: doc.id,
      userIds: userIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userIds': userIds,
    };
  }
}
