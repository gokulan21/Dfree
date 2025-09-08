import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus { pending, inProgress, completed, cancelled, onHold }
enum Priority { low, medium, high, urgent }

class ProjectModel {
  final String id;
  final String title;
  final String description;
  final String clientId;
  final String? freelancerId;
  final String clientName;
  final String? freelancerName;
  final ProjectStatus status;
  final Priority priority;
  final double budget;
  final double? paidAmount;
  final DateTime startDate;
  final DateTime dueDate;
  final DateTime? completedDate;
  final int progress;
  final List<String> skills;
  final List<String> attachments;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  ProjectModel({
    required this.id,
    required this.title,
    required this.description,
    required this.clientId,
    this.freelancerId,
    required this.clientName,
    this.freelancerName,
    required this.status,
    required this.priority,
    required this.budget,
    this.paidAmount,
    required this.startDate,
    required this.dueDate,
    this.completedDate,
    this.progress = 0,
    this.skills = const [],
    this.attachments = const [],
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      clientId: data['clientId'] ?? '',
      freelancerId: data['freelancerId'],
      clientName: data['clientName'] ?? '',
      freelancerName: data['freelancerName'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ProjectStatus.pending,
      ),
      priority: Priority.values.firstWhere(
        (e) => e.name == data['priority'],
        orElse: () => Priority.medium,
      ),
      budget: (data['budget'] ?? 0.0).toDouble(),
      paidAmount: data['paidAmount']?.toDouble(),
      startDate: (data['startDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      completedDate: (data['completedDate'] as Timestamp?)?.toDate(),
      progress: data['progress'] ?? 0,
      skills: List<String>.from(data['skills'] ?? []),
      attachments: List<String>.from(data['attachments'] ?? []),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'clientId': clientId,
      'freelancerId': freelancerId,
      'clientName': clientName,
      'freelancerName': freelancerName,
      'status': status.name,
      'priority': priority.name,
      'budget': budget,
      'paidAmount': paidAmount,
      'startDate': Timestamp.fromDate(startDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'completedDate': completedDate != null ? Timestamp.fromDate(completedDate!) : null,
      'progress': progress,
      'skills': skills,
      'attachments': attachments,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  ProjectModel copyWith({
    String? id,
    String? title,
    String? description,
    String? clientId,
    String? freelancerId,
    String? clientName,
    String? freelancerName,
    ProjectStatus? status,
    Priority? priority,
    double? budget,
    double? paidAmount,
    DateTime? startDate,
    DateTime? dueDate,
    DateTime? completedDate,
    int? progress,
    List<String>? skills,
    List<String>? attachments,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clientId: clientId ?? this.clientId,
      freelancerId: freelancerId ?? this.freelancerId,
      clientName: clientName ?? this.clientName,
      freelancerName: freelancerName ?? this.freelancerName,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      budget: budget ?? this.budget,
      paidAmount: paidAmount ?? this.paidAmount,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      progress: progress ?? this.progress,
      skills: skills ?? this.skills,
      attachments: attachments ?? this.attachments,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isOverdue {
    return DateTime.now().isAfter(dueDate) && status != ProjectStatus.completed;
  }

  String get statusDisplayName {
    switch (status) {
      case ProjectStatus.pending:
        return 'Pending';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
      case ProjectStatus.onHold:
        return 'On Hold';
    }
  }

  String get priorityDisplayName {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
      case Priority.urgent:
        return 'Urgent';
    }
  }
}
