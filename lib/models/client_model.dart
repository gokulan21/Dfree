import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? phone;
  final String company;
  final String industry;
  final String description;
  final List<String> projectIds;
  final double totalSpent;
  final int activeProjects;
  final double averageRating;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime? lastActive;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.phone,
    required this.company,
    required this.industry,
    required this.description,
    this.projectIds = const [],
    this.totalSpent = 0.0,
    this.activeProjects = 0,
    this.averageRating = 0.0,
    this.preferences = const {},
    required this.createdAt,
    this.lastActive,
  });

  factory ClientModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ClientModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profileImage: data['profileImage'],
      phone: data['phone'],
      company: data['company'] ?? '',
      industry: data['industry'] ?? '',
      description: data['description'] ?? '',
      projectIds: List<String>.from(data['projectIds'] ?? []),
      totalSpent: (data['totalSpent'] ?? 0.0).toDouble(),
      activeProjects: data['activeProjects'] ?? 0,
      averageRating: (data['averageRating'] ?? 0.0).toDouble(),
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
      'company': company,
      'industry': industry,
      'description': description,
      'projectIds': projectIds,
      'totalSpent': totalSpent,
      'activeProjects': activeProjects,
      'averageRating': averageRating,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'role': 'client',
    };
  }

  ClientModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImage,
    String? phone,
    String? company,
    String? industry,
    String? description,
    List<String>? projectIds,
    double? totalSpent,
    int? activeProjects,
    double? averageRating,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return ClientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      company: company ?? this.company,
      industry: industry ?? this.industry,
      description: description ?? this.description,
      projectIds: projectIds ?? this.projectIds,
      totalSpent: totalSpent ?? this.totalSpent,
      activeProjects: activeProjects ?? this.activeProjects,
      averageRating: averageRating ?? this.averageRating,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }
}
