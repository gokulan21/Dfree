import 'package:flutter/material.dart';

// Enums
enum ProjectStatus { todo, inProgress, overdue, completed }
enum Priority { low, medium, high }
enum TaskStatus { todo, progress, done }

// Data Models
class ProjectData {
  final String id;
  final String title;
  final String client;
  final String clientId;
  final ProjectStatus status;
  final Priority priority;
  final int progress;
  final String dueDate;
  final String? completedDate;
  final String description;
  final String budget;
  final String timeSpent;
  final String notes;
  final List<TaskData> tasks;

  const ProjectData({
    required this.id,
    required this.title,
    required this.client,
    required this.clientId,
    required this.status,
    required this.priority,
    required this.progress,
    required this.dueDate,
    this.completedDate,
    required this.description,
    required this.budget,
    required this.timeSpent,
    required this.notes,
    required this.tasks,
  });

  // Helper method to get progress percentage as a double
  double get progressPercentage => progress / 100.0;

  // Helper method to check if project is overdue
  bool get isOverdue => status == ProjectStatus.overdue;

  // Helper method to check if project is completed
  bool get isCompleted => status == ProjectStatus.completed;

  // Helper method to get completed tasks count
  int get completedTasksCount => tasks.where((task) => task.status == TaskStatus.done).length;

  // Helper method to get total tasks count
  int get totalTasksCount => tasks.length;

  // Helper method to get task completion percentage
  double get taskCompletionPercentage => 
      totalTasksCount > 0 ? completedTasksCount / totalTasksCount : 0.0;

  // Copy with method for immutability
  ProjectData copyWith({
    String? id,
    String? title,
    String? client,
    String? clientId,
    ProjectStatus? status,
    Priority? priority,
    int? progress,
    String? dueDate,
    String? completedDate,
    String? description,
    String? budget,
    String? timeSpent,
    String? notes,
    List<TaskData>? tasks,
  }) {
    return ProjectData(
      id: id ?? this.id,
      title: title ?? this.title,
      client: client ?? this.client,
      clientId: clientId ?? this.clientId,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
      description: description ?? this.description,
      budget: budget ?? this.budget,
      timeSpent: timeSpent ?? this.timeSpent,
      notes: notes ?? this.notes,
      tasks: tasks ?? this.tasks,
    );
  }
}

class TaskData {
  final String id;
  final String name;
  final TaskStatus status;
  final String? description;
  final String? assignee;
  final DateTime? dueDate;
  final DateTime? completedDate;

  const TaskData({
    required this.id,
    required this.name,
    required this.status,
    this.description,
    this.assignee,
    this.dueDate,
    this.completedDate,
  });

  // Helper method to check if task is completed
  bool get isCompleted => status == TaskStatus.done;

  // Helper method to check if task is in progress
  bool get isInProgress => status == TaskStatus.progress;

  // Helper method to check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  // Copy with method for immutability
  TaskData copyWith({
    String? id,
    String? name,
    TaskStatus? status,
    String? description,
    String? assignee,
    DateTime? dueDate,
    DateTime? completedDate,
  }) {
    return TaskData(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      description: description ?? this.description,
      assignee: assignee ?? this.assignee,
      dueDate: dueDate ?? this.dueDate,
      completedDate: completedDate ?? this.completedDate,
    );
  }
}

class ClientData {
  final String id;
  final String name;
  final String contact;
  final String email;
  final String phone;
  final String industry;
  final String avatar;
  final LinearGradient avatarColor;
  final String totalRevenue;
  final List<String> projects;
  final int activeProjects;
  final String description;
  final String joinDate;
  final String lastContact;
  final String? address;
  final String? website;
  final String? notes;

  const ClientData({
    required this.id,
    required this.name,
    required this.contact,
    required this.email,
    required this.phone,
    required this.industry,
    required this.avatar,
    required this.avatarColor,
    required this.totalRevenue,
    required this.projects,
    required this.activeProjects,
    required this.description,
    required this.joinDate,
    required this.lastContact,
    this.address,
    this.website,
    this.notes,
  });

  // Helper method to get total projects count
  int get totalProjectsCount => projects.length;

  // Helper method to get completed projects count (would need project data to calculate)
  // int getCompletedProjectsCount(Map<String, ProjectData> projectData) {
  //   return projects.where((projectId) {
  //     final project = projectData[projectId];
  //     return project?.status == ProjectStatus.completed;
  //   }).length;
  // }

  // Helper method to check if client has active projects
  bool get hasActiveProjects => activeProjects > 0;

  // Helper method to get initials for avatar
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  // Copy with method for immutability
  ClientData copyWith({
    String? id,
    String? name,
    String? contact,
    String? email,
    String? phone,
    String? industry,
    String? avatar,
    LinearGradient? avatarColor,
    String? totalRevenue,
    List<String>? projects,
    int? activeProjects,
    String? description,
    String? joinDate,
    String? lastContact,
    String? address,
    String? website,
    String? notes,
  }) {
    return ClientData(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      industry: industry ?? this.industry,
      avatar: avatar ?? this.avatar,
      avatarColor: avatarColor ?? this.avatarColor,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      projects: projects ?? this.projects,
      activeProjects: activeProjects ?? this.activeProjects,
      description: description ?? this.description,
      joinDate: joinDate ?? this.joinDate,
      lastContact: lastContact ?? this.lastContact,
      address: address ?? this.address,
      website: website ?? this.website,
      notes: notes ?? this.notes,
    );
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? avatar;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.avatar,
    this.phone,
    this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
  });

  // Helper method to get user initials
  String get initials {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  // Copy with method for immutability
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatar,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Color constants used throughout the app
const Color textWhite = Colors.white;
const Color accentCyan = Color(0xFF33CFFF);
const Color accentPink = Color(0xFFFF1EC0);
const Color bgPrimary = Color(0xFF1E1A3C);
const Color bgSecondary = Color(0xFF1B1737);

// Additional color constants for better theming
const Color textGrey = Color(0xFF9CA3AF);
const Color textLight = Color(0xFFE5E7EB);
const Color borderColor = Color(0xFF374151);
const Color successGreen = Color(0xFF10B981);
const Color warningYellow = Color(0xFFF59E0B);
const Color dangerRed = Color(0xFFEF4444);

// Helper functions for ProjectStatus
String getStatusText(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.todo:
      return 'To Do';
    case ProjectStatus.inProgress:
      return 'In Progress';
    case ProjectStatus.overdue:
      return 'Overdue';
    case ProjectStatus.completed:
      return 'Completed';
  }
}

String getStatusTitle(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.todo:
      return 'To Do Projects';
    case ProjectStatus.inProgress:
      return 'In Progress Projects';
    case ProjectStatus.overdue:
      return 'Overdue Projects';
    case ProjectStatus.completed:
      return 'Completed Projects';
  }
}

Color getStatusColor(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.todo:
      return Colors.blue;
    case ProjectStatus.inProgress:
      return warningYellow;
    case ProjectStatus.overdue:
      return dangerRed;
    case ProjectStatus.completed:
      return successGreen;
  }
}

Color getStatusHeaderColor(ProjectStatus status) {
  return getStatusColor(status); // Simplified to use same color
}

IconData getStatusIcon(ProjectStatus status) {
  switch (status) {
    case ProjectStatus.todo:
      return Icons.access_time;
    case ProjectStatus.inProgress:
      return Icons.refresh;
    case ProjectStatus.overdue:
      return Icons.warning;
    case ProjectStatus.completed:
      return Icons.check_circle;
  }
}

// Helper functions for Priority
String getPriorityText(Priority priority) {
  switch (priority) {
    case Priority.low:
      return 'Low';
    case Priority.medium:
      return 'Medium';
    case Priority.high:
      return 'High';
  }
}

Color getPriorityColor(Priority priority) {
  switch (priority) {
    case Priority.low:
      return successGreen;
    case Priority.medium:
      return warningYellow;
    case Priority.high:
      return dangerRed;
  }
}

IconData getPriorityIcon(Priority priority) {
  switch (priority) {
    case Priority.low:
      return Icons.keyboard_arrow_down;
    case Priority.medium:
      return Icons.remove;
    case Priority.high:
      return Icons.keyboard_arrow_up;
  }
}

// Helper functions for TaskStatus
String getTaskStatusText(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return 'To Do';
    case TaskStatus.progress:
      return 'In Progress';
    case TaskStatus.done:
      return 'Done';
  }
}

Color getTaskStatusColor(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return textGrey;
    case TaskStatus.progress:
      return warningYellow;
    case TaskStatus.done:
      return successGreen;
  }
}

IconData getTaskStatusIcon(TaskStatus status) {
  switch (status) {
    case TaskStatus.todo:
      return Icons.radio_button_unchecked;
    case TaskStatus.progress:
      return Icons.refresh;
    case TaskStatus.done:
      return Icons.check_circle;
  }
}

// Utility functions
class AppUtils {
  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }

  // Format date
  static String formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Get time ago string
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays > 730 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays > 60 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  // Get gradient for avatar based on name
  static LinearGradient getAvatarGradient(String name) {
    final hash = name.hashCode;
    final gradients = [
      const LinearGradient(colors: [accentCyan, accentPink]),
      const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
      const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
      const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
      const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
      const LinearGradient(colors: [Color(0xFFfa709a), Color(0xFFfee140)]),
      const LinearGradient(colors: [Color(0xFFa8edea), Color(0xFFfed6e3)]),
      const LinearGradient(colors: [Color(0xFFffecd2), Color(0xFFfcb69f)]),
    ];
    return gradients[hash.abs() % gradients.length];
  }
}

// Theme-related constants
class AppTheme {
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
  
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 20.0;
  static const double fontSizeTitle = 24.0;
  
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  
  static const double avatarSizeSmall = 32.0;
  static const double avatarSizeMedium = 48.0;
  static const double avatarSizeLarge = 64.0;
  static const double avatarSizeXLarge = 80.0;
}