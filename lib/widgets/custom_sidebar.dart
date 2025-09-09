import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';

class CustomSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final String userRole;

  const CustomSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          right: BorderSide(
            color: AppColors.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Profile Section
          _buildProfileSection(),
          
          // Navigation Items
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _buildNavigationItems(),
              ),
            ),
          ),
          
          // Footer space
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return FutureBuilder(
      future: AuthService().getCurrentUserData(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20), // Reduced padding
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.borderColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44, // Slightly smaller
                height: 44,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accentCyan, AppColors.accentPink],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    user?.name.isNotEmpty == true 
                        ? user!.name[0].toUpperCase() 
                        : (userRole == 'client' ? 'C' : 'F'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18, // Reduced font size
                      fontWeight: FontWeight.bold,
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
                      user?.name ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15, // Reduced font size
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      userRole == 'client' ? 'Client Account' : 'Freelancer Account',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11, // Reduced font size
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildNavigationItems() {
    final clientItems = [
      SidebarItem(
        icon: Icons.dashboard,
        label: "Dashboard",
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
        icon: Icons.people,
        label: "Freelancers",
        isActive: selectedIndex == 2,
        onTap: () => onItemSelected(2),
      ),
      SidebarItem(
        icon: Icons.chat,
        label: "Communication",
        isActive: selectedIndex == 3,
        onTap: () => onItemSelected(3),
      ),
      SidebarItem(
        icon: Icons.bar_chart,
        label: "Reports",
        isActive: selectedIndex == 4,
        onTap: () => onItemSelected(4),
      ),
      SidebarItem(
        icon: Icons.settings,
        label: "Settings",
        isActive: selectedIndex == 5,
        onTap: () => onItemSelected(5),
      ),
    ];

    final freelancerItems = [
      SidebarItem(
        icon: Icons.dashboard,
        label: "Dashboard",
        isActive: selectedIndex == 0,
        onTap: () => onItemSelected(0),
      ),
      SidebarItem(
        icon: Icons.work,
        label: "My Projects",
        isActive: selectedIndex == 1,
        onTap: () => onItemSelected(1),
      ),
      SidebarItem(
        icon: Icons.business,
        label: "My Clients",
        isActive: selectedIndex == 2,
        onTap: () => onItemSelected(2),
      ),
      SidebarItem(
        icon: Icons.chat,
        label: "Communication",
        isActive: selectedIndex == 3,
        onTap: () => onItemSelected(3),
      ),
      SidebarItem(
        icon: Icons.bar_chart,
        label: "Reports",
        isActive: selectedIndex == 4,
        onTap: () => onItemSelected(4),
      ),
      SidebarItem(
        icon: Icons.settings,
        label: "Settings",
        isActive: selectedIndex == 5,
        onTap: () => onItemSelected(5),
      ),
    ];

    return userRole == 'client' ? clientItems : freelancerItems;
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3), // Reduced margins
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 44), // Minimum height
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Reduced padding
            decoration: BoxDecoration(
              color: isActive 
                  ? AppColors.accentCyan.withOpacity(0.15) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(
                      color: AppColors.accentCyan.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    icon,
                    color: isActive ? AppColors.accentCyan : AppColors.textGrey,
                    size: 18, // Reduced icon size
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      color: isActive ? AppColors.accentCyan : AppColors.textGrey,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 13, // Reduced font size
                    ),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
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