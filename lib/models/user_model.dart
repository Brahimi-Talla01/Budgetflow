class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoURL;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
    this.photoURL,
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoURL,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  // Convertir en Map pour la sauvegarde dans Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoURL': photoURL,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Créer un UserModel à partir d'une Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      createdAt: map['createdAt'] is String
          ? DateTime.parse(map['createdAt'])
          : (map['createdAt']?.toDate() ?? DateTime.now()),
    );
  }
}
