class Users {
  final String id;
  final String email;
  final String fullName;
  final String role; // ✅ ADD THIS

  Users({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role, // ✅ ADD THIS
  });

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'].toString(),
      email: json['email'],
      fullName: json['name'] ?? 'Admin',
      role: json['role'] ?? 'Users',
    );
  }
}