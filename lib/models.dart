// models.dart
class Freelancer {
  final String? id; // Add ID field for Firestore document ID
  final String name;
  final String role;
  final double rating;
  final List<String> skills;
  final int workload;
  final String email;
  final String phone;
  final String bio;

  Freelancer({
    this.id,
    required this.name,
    required this.role,
    required this.rating,
    required this.skills,
    required this.workload,
    required this.email,
    required this.phone,
    required this.bio,
  });

  // Copy with method
  Freelancer copyWith({
    String? id,
    String? name,
    String? role,
    double? rating,
    List<String>? skills,
    int? workload,
    String? email,
    String? phone,
    String? bio,
  }) {
    return Freelancer(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      skills: skills ?? List.from(this.skills),
      workload: workload ?? this.workload,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'rating': rating,
      'skills': skills,
      'workload': workload,
      'email': email,
      'phone': phone,
      'bio': bio,
    };
  }

  // Create from map
  factory Freelancer.fromMap(Map<String, dynamic> map, String id) {
    return Freelancer(
      id: id,
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
      skills: List<String>.from(map['skills'] ?? []),
      workload: map['workload'] ?? 0,
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      bio: map['bio'] ?? '',
    );
  }
}

class Project {
  final String? id; // Add ID field
  final String name;
  final String assignee;
  final String dueDate;
  final ProjectStatus status;
  final int progress;
  final Priority priority;
  final String description;

  Project({
    this.id,
    required this.name,
    required this.assignee,
    required this.dueDate,
    required this.status,
    required this.progress,
    required this.priority,
    required this.description,
  });

  // Copy with method
  Project copyWith({
    String? id,
    String? name,
    String? assignee,
    String? dueDate,
    ProjectStatus? status,
    int? progress,
    Priority? priority,
    String? description,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      priority: priority ?? this.priority,
      description: description ?? this.description,
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'assignee': assignee,
      'dueDate': dueDate,
      'status': status.name,
      'progress': progress,
      'priority': priority.name,
      'description': description,
    };
  }

  // Create from map
  factory Project.fromMap(Map<String, dynamic> map, String id) {
    return Project(
      id: id,
      name: map['name'] ?? '',
      assignee: map['assignee'] ?? '',
      dueDate: map['dueDate'] ?? '',
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ProjectStatus.pending,
      ),
      progress: map['progress'] ?? 0,
      priority: Priority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => Priority.medium,
      ),
      description: map['description'] ?? '',
    );
  }
}

// Keep existing enums and ChatMessage class unchanged
enum ProjectStatus { 
  inProgress,
  completed,
  overdue,
  pending,
}

enum Priority { 
  low,
  medium,
  high,
}

class ChatMessage {
  final String message;
  final bool isReceived;
  final String time;
  final DateTime? timestamp;
  final String? senderId;

  ChatMessage({
    required this.message,
    required this.isReceived,
    required this.time,
    this.timestamp,
    this.senderId,
  });
}
