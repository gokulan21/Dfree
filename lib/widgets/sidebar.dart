// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

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
            // Profile Section
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
              child: Row(
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
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "John Client",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          "Premium Account",
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
                      isActive: selectedIndex == 0,
                      onTap: () => onItemSelected(0),
                    ),
                    SidebarItem(
                      icon: Icons.work,
                      label: "Projects",
                      isActive: selectedIndex == 1,
                      onTap: () => onItemSelected(1),
                    ),
                    SidebarItem(
                      icon: Icons.chat,
                      label: "Communication",
                      isActive: selectedIndex == 2,
                      onTap: () => onItemSelected(2),
                    ),
                    SidebarItem(
                      icon: Icons.bar_chart,
                      label: "Reports",
                      isActive: selectedIndex == 3,
                      onTap: () => onItemSelected(3),
                    ),
                    SidebarItem(
                      icon: Icons.settings,
                      label: "Settings",
                      isActive: selectedIndex == 4,
                      onTap: () => onItemSelected(4),
                    ),
                  ],
                ),
              ),
            ),
            
            // Footer spacing to prevent bottom cutoff
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
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