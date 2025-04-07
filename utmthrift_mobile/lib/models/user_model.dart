class UserModel {
  final String name;
  final String email;
  final String contact;
  final String matric;
  final String? profilePicture;
  final String userType; 
  final String gender; 
  final String location; 
  final String status; 
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
    required this.status,
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
      status: json['status'] ?? '',
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
    String? status,
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
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      createdAtFormatted: createdAtFormatted ?? this.createdAtFormatted,
    );
  }

}
