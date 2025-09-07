// sidebar.dart
// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import '../service/firestore_service.dart';
import '../service/auth_service.dart';

class CustomSidebar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await _firestoreService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF151229),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF33CFFF).withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Dynamic Profile Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
              child: _isLoading
                  ? const Row(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33CFFF)),
                          strokeWidth: 2,
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Loading...",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF33CFFF), Color(0xFFFF1EC0)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              _getUserInitial(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _getUserDisplayName(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                _getUserRole(),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
            
            // Navigation Items
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    SidebarItem(
                      icon: Icons.home,
                      label: "Home",
                      isActive: widget.selectedIndex == 0,
                      onTap: () => widget.onItemSelected(0),
                    ),
                    SidebarItem(
                      icon: Icons.work,
                      label: "Projects",
                      isActive: widget.selectedIndex == 1,
                      onTap: () => widget.onItemSelected(1),
                    ),
                    SidebarItem(
                      icon: Icons.chat,
                      label: "Communication",
                      isActive: widget.selectedIndex == 2,
                      onTap: () => widget.onItemSelected(2),
                    ),
                    SidebarItem(
                      icon: Icons.bar_chart,
                      label: "Reports",
                      isActive: widget.selectedIndex == 3,
                      onTap: () => widget.onItemSelected(3),
                    ),
                    SidebarItem(
                      icon: Icons.settings,
                      label: "Settings",
                      isActive: widget.selectedIndex == 4,
                      onTap: () => widget.onItemSelected(4),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer with user actions
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (_userProfile != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF33CFFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Account Status",
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getAccountStatus(),
                            style: const TextStyle(
                              color: Color(0xFF33CFFF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getUserInitial() {
    final name = _userProfile?['fullName'] ?? _userProfile?['username'] ?? 'U';
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String _getUserDisplayName() {
    return _userProfile?['fullName'] ?? _userProfile?['username'] ?? 'User';
  }

  String _getUserRole() {
    final role = _userProfile?['role'] ?? 'user';
    switch (role.toLowerCase()) {
      case 'client':
        return 'Premium Client';
      case 'freelancer':
        return 'Freelancer';
      default:
        return 'User Account';
    }
  }

  String _getAccountStatus() {
    final isActive = _userProfile?['isActive'] ?? false;
    final role = _userProfile?['role'] ?? '';
    
    if (!isActive) return 'Inactive';
    if (role.toLowerCase() == 'client') return 'Premium Account';
    return 'Active Account';
  }
}

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive 
                  ? const Color(0xFF33CFFF).withOpacity(0.2) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: const Color(0xFF33CFFF).withOpacity(0.3),
                      width: 1,
                    )
                  : null,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF33CFFF).withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? const Color(0xFF33CFFF) : Colors.grey[400],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF33CFFF) : Colors.grey[400],
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
