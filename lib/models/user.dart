class AppUser {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  AppUser({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.lastLoginAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: DateTime.parse(json['lastLoginAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'createdAt': createdAt.toIso8601String(),
        'lastLoginAt': lastLoginAt.toIso8601String(),
      };
}
