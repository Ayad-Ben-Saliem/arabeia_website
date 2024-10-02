import 'package:crypto/crypto.dart';
import 'dart:convert';

class User {
  int userId;
  String username;
  String email;
  String password;
  String role;

  User({
    required this.userId,
    required this.username,
    required this.email,
    required String password,
    required this.role,
  }) : password = _hashPassword(password);

  void setPassword(String password) {
    this.password = _hashPassword(password);
  }

  static String _hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to UTF8
    var digest = sha256.convert(bytes); // Hash it using SHA-256
    return digest.toString();
  }

  bool verifyPassword(String password) {
    return _hashPassword(password) == this.password;
  }

  // Equality operator to compare users based on userId
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! User) return false;
    return userId == other.userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'User(userId: $userId, username: $username, email: $email, role: $role)';
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
    );
  }
}
