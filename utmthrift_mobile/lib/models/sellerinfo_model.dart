class SellerInfo {
  final int id;
  final String? storeName;
  final String? name;
  final String? contact;
  final String? userRole;
  final String? faculty;
  final String? location;

  SellerInfo({
    required this.id,
    this.storeName,
    this.name,
    this.contact,
    this.userRole,
    this.faculty,
    this.location,
  });

  factory SellerInfo.fromJson(Map<String, dynamic> json) {
    return SellerInfo(
      id: json['id'],
      storeName: json['store_name'],
      name: json['name'],
      contact: json['contact'],
      userRole: json['user_role'],
      faculty: json['faculty'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_name': storeName,
      'name': name,
      'contact': contact,
      'user_role': userRole,
      'faculty': faculty,
      'location': location,
    };
  }
}
