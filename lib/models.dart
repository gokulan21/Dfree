// ignore_for_file: unnecessary_brace_in_string_interps

class Freelancer {
  final String name;
  final String role;
  final double rating;
  final List<String> skills;
  final int workload;
  final String email;
  final String phone;
  final String bio;

  Freelancer({
    required this.name,
    required this.role,
    required this.rating,
    required this.skills,
    required this.workload,
    required this.email,
    required this.phone,
    required this.bio,
  }) : assert(name.trim().isNotEmpty, 'Name cannot be empty'),
       assert(role.trim().isNotEmpty, 'Role cannot be empty'),
       assert(rating >= 0.0 && rating <= 5.0, 'Rating must be between 0.0 and 5.0'),
       assert(workload >= 0 && workload <= 100, 'Workload must be between 0 and 100'),
       assert(email.trim().isNotEmpty, 'Email cannot be empty'),
       assert(phone.trim().isNotEmpty, 'Phone cannot be empty'),
       assert(bio.trim().isNotEmpty, 'Bio cannot be empty');

  // Helper methods for UI display
  String get displayName => name.trim();
  String get displayRole => role.trim();
  String get displayEmail => email.trim();
  String get displayPhone => phone.trim();
  String get displayBio => bio.trim();
  
  // Safe rating display
  String get ratingText => rating.toStringAsFixed(1);
  
  // Safe workload display
  String get workloadText => '$workload%';
  
  // Safe avatar initial
  String get avatarInitial {
    final trimmedName = name.trim();
    return trimmedName.isNotEmpty ? trimmedName[0].toUpperCase() : '?';
  }
  
  // Filtered skills (remove empty skills)
  List<String> get validSkills => skills
      .where((skill) => skill.trim().isNotEmpty)
      .map((skill) => skill.trim())
      .toList();
  
  // Status based on workload
  String get workloadStatus {
    if (workload >= 90) return 'Overloaded';
    if (workload >= 75) return 'High';
    if (workload >= 50) return 'Medium';
    if (workload >= 25) return 'Low';
    return 'Available';
  }
  
  // Color for workload status
  int get workloadColor {
    if (workload >= 90) return 0xFFFF0000; // Red
    if (workload >= 75) return 0xFFFF8C00; // Orange
    if (workload >= 50) return 0xFFFFD700; // Gold
    if (workload >= 25) return 0xFF32CD32; // Green
    return 0xFF00CED1; // Cyan
  }

  // Copy with method for updates
  Freelancer copyWith({
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

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Freelancer &&
        other.name == name &&
        other.role == role &&
        other.rating == rating &&
        _listEquals(other.skills, skills) &&
        other.workload == workload &&
        other.email == email &&
        other.phone == phone &&
        other.bio == bio;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      role,
      rating,
      skills,
      workload,
      email,
      phone,
      bio,
    );
  }

  @override
  String toString() {
    return 'Freelancer(name: $name, role: $role, rating: $rating, workload: $workload%)';
  }
}

enum ProjectStatus { 
  inProgress('In Progress', 0xFF33CFFF),
  completed('Completed', 0xFF32CD32),
  overdue('Overdue', 0xFFFF0000),
  pending('Pending', 0xFFFFD700);

  const ProjectStatus(this.displayName, this.colorValue);
  
  final String displayName;
  final int colorValue;
  
  // Helper method to get status from string
  static ProjectStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
      case 'inprogress':
        return ProjectStatus.inProgress;
      case 'completed':
        return ProjectStatus.completed;
      case 'overdue':
        return ProjectStatus.overdue;
      case 'pending':
        return ProjectStatus.pending;
      default:
        return ProjectStatus.pending;
    }
  }
}

enum Priority { 
  low('Low', 0xFF32CD32),
  medium('Medium', 0xFFFFD700),
  high('High', 0xFFFF0000);

  const Priority(this.displayName, this.colorValue);
  
  final String displayName;
  final int colorValue;
  
  // Helper method to get priority from string
  static Priority fromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return Priority.low;
      case 'medium':
        return Priority.medium;
      case 'high':
        return Priority.high;
      default:
        return Priority.medium;
    }
  }
}

class Project {
  final String name;
  final String assignee;
  final String dueDate;
  final ProjectStatus status;
  final int progress;
  final Priority priority;
  final String description;

  Project({
    required this.name,
    required this.assignee,
    required this.dueDate,
    required this.status,
    required this.progress,
    required this.priority,
    required this.description,
  }) : assert(name.trim().isNotEmpty, 'Project name cannot be empty'),
       assert(assignee.trim().isNotEmpty, 'Assignee cannot be empty'),
       assert(dueDate.trim().isNotEmpty, 'Due date cannot be empty'),
       assert(progress >= 0 && progress <= 100, 'Progress must be between 0 and 100'),
       assert(description.trim().isNotEmpty, 'Description cannot be empty');

  // Helper methods for UI display
  String get displayName => name.trim();
  String get displayAssignee => assignee.trim();
  String get displayDueDate => dueDate.trim();
  String get displayDescription => description.trim();
  
  // Safe progress display
  String get progressText => '$progress%';
  double get progressFraction => (progress / 100.0).clamp(0.0, 1.0);
  
  // Status helpers
  String get statusText => status.displayName;
  int get statusColor => status.colorValue;
  
  // Priority helpers
  String get priorityText => priority.displayName;
  int get priorityColor => priority.colorValue;
  
  // Project health status
  String get healthStatus {
    if (status == ProjectStatus.overdue) return 'Critical';
    if (status == ProjectStatus.completed) return 'Completed';
    if (progress >= 80) return 'On Track';
    if (progress >= 50) return 'In Progress';
    if (progress >= 25) return 'Started';
    return 'Not Started';
  }
  
  // Days until due (simplified - you might want to use DateTime for real apps)
  String get timeStatus {
    if (status == ProjectStatus.completed) return 'Completed';
    if (status == ProjectStatus.overdue) return 'Overdue';
    return 'Due ${displayDueDate}';
  }
  
  // Is project urgent
  bool get isUrgent {
    return status == ProjectStatus.overdue || 
           (priority == Priority.high && progress < 80);
  }
  
  // Estimated completion
  String get completionEstimate {
    if (status == ProjectStatus.completed) return 'Completed';
    if (progress == 0) return 'Not started';
    if (progress >= 90) return 'Almost done';
    if (progress >= 75) return 'Nearly complete';
    if (progress >= 50) return 'Halfway there';
    if (progress >= 25) return 'In progress';
    return 'Just started';
  }

  // Copy with method for updates
  Project copyWith({
    String? name,
    String? assignee,
    String? dueDate,
    ProjectStatus? status,
    int? progress,
    Priority? priority,
    String? description,
  }) {
    return Project(
      name: name ?? this.name,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      priority: priority ?? this.priority,
      description: description ?? this.description,
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Project &&
        other.name == name &&
        other.assignee == assignee &&
        other.dueDate == dueDate &&
        other.status == status &&
        other.progress == progress &&
        other.priority == priority &&
        other.description == description;
  }

  @override
  int get hashCode {
    return Object.hash(
      name,
      assignee,
      dueDate,
      status,
      progress,
      priority,
      description,
    );
  }

  @override
  String toString() {
    return 'Project(name: $name, assignee: $assignee, progress: $progress%, status: ${status.displayName})';
  }
}

class ChatMessage {
  final String message;
  final bool isReceived;
  final String time;
  final DateTime? timestamp;
  final String? senderId;
  final MessageType type;

  ChatMessage({
    required this.message,
    required this.isReceived,
    required this.time,
    this.timestamp,
    this.senderId,
    this.type = MessageType.text,
  }) : assert(message.trim().isNotEmpty, 'Message cannot be empty'),
       assert(time.trim().isNotEmpty, 'Time cannot be empty');

  // Helper methods for UI display
  String get displayMessage => message.trim();
  String get displayTime => time.trim();
  
  // Safe sender display
  String get displaySender => senderId?.trim() ?? (isReceived ? 'Freelancer' : 'You');
  
  // Message preview (for chat lists)
  String get preview {
    final msg = displayMessage;
    if (msg.length <= 50) return msg;
    return '${msg.substring(0, 47)}...';
  }
  
  // Is message recent (within last hour)
  bool get isRecent {
    if (timestamp == null) return false;
    final now = DateTime.now();
    final difference = now.difference(timestamp!);
    return difference.inHours < 1;
  }
  
  // Message status
  MessageStatus get status {
    if (isReceived) return MessageStatus.received;
    // You could expand this to include sent, delivered, read, etc.
    return MessageStatus.sent;
  }

  // Copy with method for updates
  ChatMessage copyWith({
    String? message,
    bool? isReceived,
    String? time,
    DateTime? timestamp,
    String? senderId,
    MessageType? type,
  }) {
    return ChatMessage(
      message: message ?? this.message,
      isReceived: isReceived ?? this.isReceived,
      time: time ?? this.time,
      timestamp: timestamp ?? this.timestamp,
      senderId: senderId ?? this.senderId,
      type: type ?? this.type,
    );
  }

  // Equality and hashCode
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.message == message &&
        other.isReceived == isReceived &&
        other.time == time &&
        other.timestamp == timestamp &&
        other.senderId == senderId &&
        other.type == type;
  }

  @override
  int get hashCode {
    return Object.hash(
      message,
      isReceived,
      time,
      timestamp,
      senderId,
      type,
    );
  }

  @override
  String toString() {
    return 'ChatMessage(message: ${preview}, isReceived: $isReceived, time: $time)';
  }
}

enum MessageType {
  text('Text'),
  image('Image'),
  file('File'),
  system('System');

  const MessageType(this.displayName);
  final String displayName;
}

enum MessageStatus {
  sent('Sent'),
  delivered('Delivered'),
  received('Received'),
  read('Read');

  const MessageStatus(this.displayName);
  final String displayName;
}

// Helper function for list equality
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  if (identical(a, b)) return true;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

// Extension methods for additional utility
extension FreelancerExtension on Freelancer {
  // Check if freelancer is available for new projects
  bool get isAvailable => workload < 85;
  
  // Get skill count
  int get skillCount => validSkills.length;
  
  // Check if freelancer has specific skill
  bool hasSkill(String skill) {
    return validSkills.any((s) => s.toLowerCase().contains(skill.toLowerCase()));
  }
}

extension ProjectExtension on Project {
  // Check if project needs attention
  bool get needsAttention {
    return status == ProjectStatus.overdue || 
           (priority == Priority.high && progress < 50);
  }
  
  // Get days overdue (simplified)
  bool get isOverdue => status == ProjectStatus.overdue;
  
  // Progress category
  String get progressCategory {
    if (progress >= 90) return 'Almost Complete';
    if (progress >= 75) return 'Nearly Done';
    if (progress >= 50) return 'Halfway';
    if (progress >= 25) return 'In Progress';
    return 'Getting Started';
  }
}