class UserProfileModel {
  final String name;
  final String email;
  final String? imageUrl;

  UserProfileModel({required this.name, required this.email, this.imageUrl});

  Map<String, dynamic> toMap() {
    return {'name': name, 'email': email, 'imageUrl': imageUrl};
  }

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      imageUrl: map['imageUrl'],
    );
  }
}
