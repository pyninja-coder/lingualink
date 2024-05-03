class User {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;
  final String language; // New field for language preference

  User({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
    required this.language,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'],
      email: json['email'],
      displayName: json['displayName'],
      photoURL: json['photoURL'],
      language: json['language'] ?? 'en', // Default language to English if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'language': language,
    };
  }
}
