// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../widgets/custom_card.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';
import '../../screens/auth/login_page.dart';

class ClientSettingsPage extends StatefulWidget {
  const ClientSettingsPage({super.key});

  @override
  State<ClientSettingsPage> createState() => _ClientSettingsPageState();
}

class _ClientSettingsPageState extends State<ClientSettingsPage> {
  final AuthService _authService = AuthService();
  
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _bioController = TextEditingController();
  
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;
  
  // Notification preferences
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _projectUpdates = true;
  bool _messageNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUserData();
      if (userData != null && mounted) {
        setState(() {
          _currentUser = userData;
          _nameController.text = userData.name;
          _emailController.text = userData.email;
          _phoneController.text = userData.phone ?? '';
          _companyController.text = userData.company ?? '';
          _bioController.text = userData.bio ?? '';
          
          // Load notification preferences
          _emailNotifications = userData.preferences['emailNotifications'] ?? true;
          _pushNotifications = userData.preferences['pushNotifications'] ?? true;
          _projectUpdates = userData.preferences['projectUpdates'] ?? true;
          _messageNotifications = userData.preferences['messageNotifications'] ?? true;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user data: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'company': _companyController.text.trim(),
        'bio': _bioController.text.trim(),
        'preferences': {
          'emailNotifications': _emailNotifications,
          'pushNotifications': _pushNotifications,
          'projectUpdates': _projectUpdates,
          'messageNotifications': _messageNotifications,
        },
      };

      await _authService.updateUserProfile(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: ${e.toString()}'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardColor,
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _authService.signOut();
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error signing out: ${e.toString()}'),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: LoadingWidget());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Account Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Profile Section
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 1024) {
                return Column(
                  children: [
                    _buildProfileSection(),
                    const SizedBox(height: 24),
                    _buildNotificationSection(),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildProfileSection()),
                    const SizedBox(width: 24),
                    Expanded(child: _buildNotificationSection()),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 24),
          
          // Account Actions
          _buildAccountActions(),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile Picture
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accentCyan, AppColors.accentPink],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _currentUser?.name.isNotEmpty == true 
                            ? _currentUser!.name[0].toUpperCase() 
                            : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.accentCyan,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Form fields
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                helperText: 'Email cannot be changed',
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'Company',
                prefixIcon: Icon(Icons.business_outlined),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                prefixIcon: Icon(Icons.description_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            
            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notification Preferences',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            _buildNotificationSwitch(
              'Email Notifications',
              'Receive updates via email',
              _emailNotifications,
              (value) => setState(() => _emailNotifications = value),
            ),
            
            _buildNotificationSwitch(
              'Push Notifications',
              'Receive push notifications',
              _pushNotifications,
              (value) => setState(() => _pushNotifications = value),
            ),
            
            _buildNotificationSwitch(
              'Project Updates',
              'Get notified about project progress',
              _projectUpdates,
              (value) => setState(() => _projectUpdates = value),
            ),
            
            _buildNotificationSwitch(
              'Message Notifications',
              'Get notified about new messages',
              _messageNotifications,
              (value) => setState(() => _messageNotifications = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accentCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountActions() {
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Actions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // Change Password
            ListTile(
              leading: const Icon(Icons.lock_outline, color: AppColors.accentCyan),
              title: const Text(
                'Change Password',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Update your account password',
                style: TextStyle(color: AppColors.textGrey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
              onTap: () {
                // Show change password dialog
              },
            ),
            
            const Divider(color: AppColors.borderColor),
            
            // Export Data
            ListTile(
              leading: const Icon(Icons.download, color: AppColors.accentCyan),
              title: const Text(
                'Export Data',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Download your account data',
                style: TextStyle(color: AppColors.textGrey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
              onTap: () {
                // Export data functionality
              },
            ),
            
            const Divider(color: AppColors.borderColor),
            
            // Sign Out
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.dangerRed),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.dangerRed),
              ),
              subtitle: const Text(
                'Sign out of your account',
                style: TextStyle(color: AppColors.textGrey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
              onTap: _signOut,
            ),
            
            const Divider(color: AppColors.borderColor),
            
            // Delete Account
            ListTile(
              leading: const Icon(Icons.delete_forever, color: AppColors.dangerRed),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: AppColors.dangerRed),
              ),
              subtitle: const Text(
                'Permanently delete your account',
                style: TextStyle(color: AppColors.textGrey),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.textGrey, size: 16),
              onTap: () {
                // Show delete account confirmation
              },
            ),
          ],
        ),
      ),
    );
  }
}