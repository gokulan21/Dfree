// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';

class AppColors {
  static const Color bgPrimary = Color(0xFF1E1A3C);
  static const Color bgSecondary = Color(0xFF1B1737);
  static const Color accentCyan = Color(0xFF33CFFF);
  static const Color accentPink = Color(0xFFFF1EC0);
  static const Color textWhite = Colors.white;
  static const Color textGrey = Color(0xFF9CA3AF);
  static const Color textLight = Color(0xFFE5E7EB);
  static const Color borderColor = Color(0xFF374151);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color cardColor = Color(0xFF262047);
}

class AppSizes {
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

class AppStrings {
  static const String appName = 'FreelanceHub';
  static const String tagline = 'Connect. Create. Collaborate.';
  
  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String logout = 'Logout';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  
  // Common
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String create = 'Create';
  static const String update = 'Update';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  
  // Navigation
  static const String dashboard = 'Dashboard';
  static const String projects = 'Projects';
  static const String clients = 'Clients';
  static const String freelancers = 'Freelancers';
  static const String communication = 'Communication';
  static const String reports = 'Reports';
  static const String settings = 'Settings';
  
  // Project Status
  static const String pending = 'Pending';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';
  static const String onHold = 'On Hold';
  
  // Priority
  static const String low = 'Low';
  static const String medium = 'Medium';
  static const String high = 'High';
  static const String urgent = 'Urgent';
}

class AppConstants {
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedFileTypes = ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'];
  static const int maxMessageLength = 1000;
  static const int maxProjectTitleLength = 100;
  static const int maxProjectDescriptionLength = 2000;
  static const double minHourlyRate = 5.0;
  static const double maxHourlyRate = 1000.0;
  static const double minProjectBudget = 50.0;
  static const double maxProjectBudget = 100000.0;
}

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String clientDashboard = '/client-dashboard';
  static const String freelancerDashboard = '/freelancer-dashboard';
  static const String projects = '/projects';
  static const String chat = '/chat';
  static const String settings = '/settings';
}

// Enums
enum UserRole { client, freelancer }
enum ProjectStatusEnum { pending, inProgress, completed, cancelled, onHold }
enum PriorityEnum { low, medium, high, urgent }
enum MessageTypeEnum { text, image, file, system }

// Extensions
extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  bool get isValidPhone {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(this);
  }
}

extension DateTimeExtension on DateTime {
  String get timeAgo {
    try {
      final now = DateTime.now();
      final difference = now.difference(this);

      if (difference.inDays > 365) {
        final years = (difference.inDays / 365).floor();
        return '$years year${years > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 30) {
        final months = (difference.inDays / 30).floor();
        return '$months month${months > 1 ? 's' : ''} ago';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }
  
  String get formatDate {
    try {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      if (month < 1 || month > 12) return 'Invalid date';
      
      return '${months[month - 1]} $day, $year';
    } catch (e) {
      return 'Invalid date';
    }
  }
  
  String get formatDateTime {
    try {
      return '${formatDate} at ${formatTime}';
    } catch (e) {
      return 'Invalid date time';
    }
  }
  
  String get formatTime {
    try {
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final period = hour >= 12 ? 'PM' : 'AM';
      final hourStr = displayHour.toString().padLeft(2, '0');
      final minuteStr = minute.toString().padLeft(2, '0');
      
      return '$hourStr:$minuteStr $period';
    } catch (e) {
      return 'Invalid time';
    }
  }
}