class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime createdAt;
  final List<String> emergencyContactIds;
  final bool isVerified;

  UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.phoneNumber,
    this.photoUrl,
    required this.createdAt,
    this.emergencyContactIds = const [],
    this.isVerified = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      uid: documentId,
      email: data['email'] ?? '',
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      photoUrl: data['photoUrl'],
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt'].toString()) 
          : DateTime.now(),
      emergencyContactIds: List<String>.from(data['emergencyContactIds'] ?? []),
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'emergencyContactIds': emergencyContactIds,
      'isVerified': isVerified,
    };
  }
}
