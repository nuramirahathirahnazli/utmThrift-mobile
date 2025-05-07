class UserModel {
  final String name;
  final String email;
  final String contact;
  final String matric;
  final String? profilePicture;
  final String userType; 
  final String gender; 
  final String location; 
  final String userRole; 
  final DateTime createdAt;
  final String createdAtFormatted;

  UserModel({
    required this.name,
    required this.email,
    required this.contact,
    required this.matric,
    this.profilePicture,
    required this.userType,
    required this.gender,
    required this.location,
    required this.userRole,
    required this.createdAt,
    this.createdAtFormatted = "",
  });

  // Convert JSON response into UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
     String? profilePic = json['profile_picture'];

    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      contact: json['contact'] ?? '',
      matric: json['matric'] ?? '',
      profilePicture: profilePic, 
      userType: json['user_type'] ?? '',
      gender: json['gender'] ?? '',
      location: json['location'] ?? '',
      userRole: json['user_role'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  // CopyWith method to allow easy updates to the UserModel object
  UserModel copyWith({
    String? name,
    String? email,
    String? contact,
    String? matric,
    String? profilePicture,
    String? userType,
    String? gender,
    String? location,
    String? userRole,
    DateTime? createdAt,
    String? createdAtFormatted,
  }) {
    return UserModel(
      name: name ?? this.name,
      email: email ?? this.email,
      contact: contact ?? this.contact,
      matric: matric ?? this.matric,
      profilePicture: profilePicture ?? this.profilePicture,
      userType: userType ?? this.userType,
      gender: gender ?? this.gender,
      location: location ?? this.location,
      userRole: userRole ?? this.userRole,
      createdAt: createdAt ?? this.createdAt,
      createdAtFormatted: createdAtFormatted ?? this.createdAtFormatted,
    );
  }

}
