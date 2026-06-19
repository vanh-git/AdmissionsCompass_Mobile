class AppUser {
  final String email;
  final String displayName;

  AppUser({required this.email, required this.displayName});

  Map<String, dynamic> toJson() => {'email': email, 'displayName': displayName};

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
    );
  }
}
