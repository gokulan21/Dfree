import 'package:cloud_firestore/cloud_firestore.dart';

class FreelancerModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phone;
  final String bio;
  final List<String> skills;
  final double hourlyRate;
  final double rating;
  final int totalProjects;
  final int completedProjects;
  final bool isAvailable;
  final String portfolio;
  final String experience;
  final List<String> certifications;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime? lastActive;

  FreelancerModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phone,
    required this.bio,
    required this.skills,
    required this.hourlyRate,
    this.rating = 0.0,
    this.totalProjects = 0,
    this.completedProjects = 0,
    this.isAvailable = true,
    this.portfolio = '',
    this.experience = '',
    this.certifications = const [],
    this.preferences = const {},
    required this.createdAt,
    this.lastActive,
  });

  factory FreelancerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FreelancerModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profileImage: data['profileImage'],
      phone: data['phone'],
      bio: data['bio'] ?? '',
      skills: List<String>.from(data['skills'] ?? []),
      hourlyRate: (data['hourlyRate'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalProjects: data['totalProjects'] ?? 0,
      completedProjects: data['completedProjects'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      portfolio: data['portfolio'] ?? '',
      experience: data['experience'] ?? '',
      certifications: List<String>.from(data['certifications'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'phone': phone,
      'bio': bio,
      'skills': skills,
      'hourlyRate': hourlyRate,
      'rating': rating,
      'totalProjects': totalProjects,
      'completedProjects': completedProjects,
      'isAvailable': isAvailable,
      'portfolio': portfolio,
      'experience': experience,
      'certifications': certifications,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'role': 'freelancer',
    };
  }

  FreelancerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? phone,
    String? bio,
    List<String>? skills,
    double? hourlyRate,
    double? rating,
    int? totalProjects,
    int? completedProjects,
    bool? isAvailable,
    String? portfolio,
    String? experience,
    List<String>? certifications,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return FreelancerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      rating: rating ?? this.rating,
      totalProjects: totalProjects ?? this.totalProjects,
      completedProjects: completedProjects ?? this.completedProjects,
      isAvailable: isAvailable ?? this.isAvailable,
      portfolio: portfolio ?? this.portfolio,
      experience: experience ?? this.experience,
      certifications: certifications ?? this.certifications,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
