import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'client' or 'freelancer'
  final String? profileImage;
  final String? phone;
  final String? company;
  final String? bio;
  final List<String> skills;
  final double hourlyRate;
  final double rating;
  final int totalProjects;
  final int completedProjects;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
    this.phone,
    this.company,
    this.bio,
    this.skills = const [],
    this.hourlyRate = 0.0,
    this.rating = 0.0,
    this.totalProjects = 0,
    this.completedProjects = 0,
    required this.createdAt,
    this.lastLogin,
    this.isActive = true,
    this.preferences = const {},
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'client',
      profileImage: data['profileImage'],
      phone: data['phone'],
      company: data['company'],
      bio: data['bio'],
      skills: List<String>.from(data['skills'] ?? []),
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalProjects: data['totalProjects'] ?? 0,
      completedProjects: data['completedProjects'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'phone': phone,
      'company': company,
      'bio': bio,
      'skills': skills,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'totalProjects': totalProjects,
      'completedProjects': completedProjects,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
      'isActive': isActive,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? profileImage,
    String? phone,
    String? company,
    String? bio,
    List<String>? skills,
    double? hourlyRate,
    double? rating,
    int? totalProjects,
    int? completedProjects,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isActive,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      totalProjects: totalProjects ?? this.totalProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isActive: isActive ?? this.isActive,
      preferences: preferences ?? this.preferences,
    );
  }
}
