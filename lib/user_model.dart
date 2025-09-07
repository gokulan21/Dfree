import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String role;
  final String fullName;
  final String company;
  final String phone;
  final String profileImage;
  final String bio;
  final List<String> skills;
  final double hourlyRate;
  final double rating;
  final int totalProjects;
  final int completedProjects;
  final DateTime? createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final String accountType;
  final String platform;
  final bool isEmailVerified;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    required this.fullName,
    required this.company,
    required this.phone,
    this.profileImage = '',
    this.bio = '',
    this.skills = const [],
    this.hourlyRate = 0.0,
    this.rating = 0.0,
    this.totalProjects = 0,
    this.completedProjects = 0,
    this.createdAt,
    this.lastLogin,
    this.isActive = true,
    required this.accountType,
    this.platform = 'android',
    this.isEmailVerified = false,
    this.preferences = const {},
  });

  // Factory constructor to create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? '',
      fullName: data['fullName'] ?? '',
      company: data['company'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalProjects: data['totalProjects'] ?? 0,
      completedProjects: data['completedProjects'] ?? 0,
      createdAt: data['createdAt']?.toDate(),
      lastLogin: data['lastLogin']?.toDate(),
      isActive: data['isActive'] ?? true,
      accountType: data['accountType'] ?? '',
      platform: data['platform'] ?? 'android',
      isEmailVerified: data['isEmailVerified'] ?? false,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'role': role,
      'fullName': fullName,
      'company': company,
      'phone': phone,
      'profileImage': profileImage,
      'bio': bio,
      'skills': skills,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'totalProjects': totalProjects,
      'completedProjects': completedProjects,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : FieldValue.serverTimestamp(),
      'isActive': isActive,
      'accountType': accountType,
      'platform': platform,
      'isEmailVerified': isEmailVerified,
      'preferences': preferences,
    };
  }

  // Copy with method for updating user data
  UserModel copyWith({
    String? uid,
    String? email,
    String? username,
    String? role,
    String? fullName,
    String? company,
    String? phone,
    String? profileImage,
    String? bio,
    List<String>? skills,
    double? hourlyRate,
    double? rating,
    int? totalProjects,
    int? completedProjects,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    String? accountType,
    String? platform,
    bool? isEmailVerified,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      totalProjects: totalProjects ?? this.totalProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      accountType: accountType ?? this.accountType,
      platform: platform ?? this.platform,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      preferences: preferences ?? this.preferences,
    );
  }
}
