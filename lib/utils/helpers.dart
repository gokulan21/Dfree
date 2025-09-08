import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class AppHelpers {
  // Date formatting
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y h:mm a').format(dateTime);
  }

  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  // Currency formatting
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return '$symbol${amount.toStringAsFixed(0)}';
    }
  }

  static String formatCurrencyFull(double amount, {String symbol = '\$'}) {
    final formatter = NumberFormat.currency(symbol: symbol, decimalDigits: 2);
    return formatter.format(amount);
  }

  // Validation helpers
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  static bool isValidUrl(String url) {
    return RegExp(r'^https?:\/\/[\w\-]+(\.[\w\-]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?$').hasMatch(url);
  }

  // String helpers
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  // Color helpers
  static Color getAvatarColor(String name) {
    final colors = [
      AppColors.accentCyan,
      AppColors.accentPink,
      AppColors.successGreen,
      AppColors.warningYellow,
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
      const Color(0xFFEC4899),
    ];
    
    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }

  static LinearGradient getAvatarGradient(String name) {
    final gradients = [
      const LinearGradient(colors: [AppColors.accentCyan, AppColors.accentPink]),
      const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)]),
      const LinearGradient(colors: [Color(0xFFf093fb), Color(0xFFf5576c)]),
      const LinearGradient(colors: [Color(0xFF4facfe), Color(0xFF00f2fe)]),
      const LinearGradient(colors: [Color(0xFF43e97b), Color(0xFF38f9d7)]),
      const LinearGradient(colors: [Color(0xFFfa709a), Color(0xFFfee140)]),
    ];
    
    final hash = name.hashCode.abs();
    return gradients[hash % gradients.length];
  }

  // File helpers
  static String getFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  static String getFileExtension(String fileName) {
    return fileName.split('.').last.toLowerCase();
  }

  static IconData getFileIcon(String fileName) {
    final extension = getFileExtension(fileName);
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  // UI helpers
  static void showSnackBar(BuildContext context, String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.dangerRed);
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(context, message, backgroundColor: AppColors.successGreen);
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: AppColors.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText, style: const TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor ?? AppColors.dangerRed,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Navigation helpers
  static void pushPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void pushReplacementPage(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void pushAndClearStack(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  // Device helpers
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 768;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 768 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  // Performance helpers
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  static void requestFocus(BuildContext context, FocusNode focusNode) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  // Data helpers
  static List<T> removeDuplicates<T>(List<T> list) {
    return list.toSet().toList();
  }

  static Map<String, dynamic> removeNullValues(Map<String, dynamic> map) {
    return Map.fromEntries(
      map.entries.where((entry) => entry.value != null),
    );
  }

  // Debug helpers
  static void debugLog(String message) {
    debugPrint('[FreelanceHub] $message');
  }

  static void debugLogError(String error, [StackTrace? stackTrace]) {
    debugPrint('[FreelanceHub ERROR] $error');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}

// Extension methods
extension StringExtensions on String {
  bool get isValidEmail => AppHelpers.isValidEmail(this);
  bool get isValidPhone => AppHelpers.isValidPhone(this);
  bool get isValidUrl => AppHelpers.isValidUrl(this);
  String get capitalize => AppHelpers.capitalize(this);
  String truncate(int maxLength) => AppHelpers.truncate(this, maxLength);
}

extension DateTimeExtensions on DateTime {
  String get formatDate => AppHelpers.formatDate(this);
  String get formatTime => AppHelpers.formatTime(this);
  String get formatDateTime => AppHelpers.formatDateTime(this);
  String get timeAgo => AppHelpers.getTimeAgo(this);
}

extension DoubleExtensions on double {
  String get formatCurrency => AppHelpers.formatCurrency(this);
  String get formatCurrencyFull => AppHelpers.formatCurrencyFull(this);
}

extension BuildContextExtensions on BuildContext {
  bool get isMobile => AppHelpers.isMobile(this);
  bool get isTablet => AppHelpers.isTablet(this);
  bool get isDesktop => AppHelpers.isDesktop(this);
  
  void showSnackBar(String message, {Color? backgroundColor}) {
    AppHelpers.showSnackBar(this, message, backgroundColor: backgroundColor);
  }
  
  void showErrorSnackBar(String message) {
    AppHelpers.showErrorSnackBar(this, message);
  }
  
  void showSuccessSnackBar(String message) {
    AppHelpers.showSuccessSnackBar(this, message);
  }
  
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) {
    return AppHelpers.showConfirmDialog(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
    );
  }
  
  void hideKeyboard() => AppHelpers.hideKeyboard(this);
}
