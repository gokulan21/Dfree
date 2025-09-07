// settings_page.dart
// ignore_for_file: unused_field, prefer_const_constructors

import 'package:flutter/material.dart';
import '../widgets/card.dart';
import '../service/firestore_service.dart';
import '../service/auth_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  
  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Notification preferences
  bool projectUpdates = true;
  bool newMessages = true;
  bool weeklyReports = false;
  
  // Loading states
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load user profile data
      final profile = await _firestoreService.getUserProfile();
      final preferences = await _getNotificationPreferences();

      if (mounted) {
        setState(() {
          _userProfile = profile;
          
          // Populate form fields with null safety
          _fullNameController.text = profile?['fullName']?.toString() ?? '';
          _emailController.text = profile?['email']?.toString() ?? '';
          _companyController.text = profile?['company']?.toString() ?? '';
          _phoneController.text = profile?['phone']?.toString() ?? '';
          
          // Set notification preferences
          projectUpdates = preferences['projectUpdates'] ?? true;
          newMessages = preferences['newMessages'] ?? true;
          weeklyReports = preferences['weeklyReports'] ?? false;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Fallback method for getting notification preferences
  Future<Map<String, dynamic>> _getNotificationPreferences() async {
    try {
      // Try to get from user profile document
      final profile = await _firestoreService.getUserProfile();
      return {
        'projectUpdates': profile?['notifications']?['projectUpdates'] ?? true,
        'newMessages': profile?['notifications']?['newMessages'] ?? true,
        'weeklyReports': profile?['notifications']?['weeklyReports'] ?? false,
      };
    } catch (e) {
      // Return default preferences if method doesn't exist
      return {
        'projectUpdates': true,
        'newMessages': true,
        'weeklyReports': false,
      };
    }
  }

  Future<void> _updateProfile() async {
    if (!mounted) return;
    
    try {
      setState(() => _isSaving = true);

      // Create update data
      final updateData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'company': _companyController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Try to use updateUserProfile method, fallback to general update
      try {
        // Check if the method exists by attempting to call it
        await _firestoreService.updateUserProfile(updateData);
      } catch (e) {
        // If updateUserProfile doesn't exist, try alternative methods
        final currentUser = _authService.getCurrentUser();
        if (currentUser != null) {
          // Fallback: update the user document directly
          await _updateUserDocument(currentUser.uid, updateData);
        } else {
          throw Exception('No authenticated user found');
        }
      }

      if (mounted) {
        _showSuccessMessage("Profile updated successfully!");
        // Reload profile to reflect changes
        await _loadUserProfile();
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage("Failed to update profile: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Fallback method to update user document
  Future<void> _updateUserDocument(String userId, Map<String, dynamic> data) async {
    // This is a fallback implementation
    // You might need to adjust this based on your FirestoreService implementation
    throw UnimplementedError(
      'updateUserProfile method not found in FirestoreService. '
      'Please implement this method in your FirestoreService class.'
    );
  }

  Future<void> _updateNotificationPreferences() async {
    if (!mounted) return;
    
    try {
      setState(() => _isSaving = true);

      final preferencesData = {
        'projectUpdates': projectUpdates,
        'newMessages': newMessages,
        'weeklyReports': weeklyReports,
      };

      try {
        // Try to use updateNotificationPreferences method
        await _firestoreService.updateNotificationPreferences(
          projectUpdates: projectUpdates,
          newMessages: newMessages,
          weeklyReports: weeklyReports,
        );
      } catch (e) {
        // Fallback: update notifications in user profile
        final currentUser = _authService.getCurrentUser();
        if (currentUser != null) {
          await _updateNotificationsInProfile(currentUser.uid, preferencesData);
        } else {
          throw Exception('No authenticated user found');
        }
      }

      if (mounted) {
        _showSuccessMessage("Preferences saved successfully!");
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage("Failed to save preferences: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // Fallback method to update notifications in user profile
  Future<void> _updateNotificationsInProfile(String userId, Map<String, dynamic> preferences) async {
    // This is a fallback implementation
    throw UnimplementedError(
      'updateNotificationPreferences method not found in FirestoreService. '
      'Please implement this method in your FirestoreService class.'
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E1A3C),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF33CFFF)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading settings...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1A3C),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Error loading settings',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _loadUserProfile,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF33CFFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1A3C),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isDesktop = constraints.maxWidth > 768;
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with responsive font size
                  Center(
                    child: Text(
                      "Account Settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isDesktop ? 32 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Responsive layout for desktop and mobile
                  if (isDesktop) 
                    _buildDesktopLayout()
                  else 
                    _buildMobileLayout(),
                  
                  const SizedBox(height: 32),
                  
                  // Logout Section
                  _buildLogoutSection(),
                  
                  // Bottom spacing to prevent content cutoff
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildProfileCard()),
        const SizedBox(width: 16),
        Expanded(child: _buildPreferencesCard()),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildProfileCard(),
        const SizedBox(height: 16),
        _buildPreferencesCard(),
      ],
    );
  }

  Widget _buildProfileCard() {
    return DashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.person,
                  color: Color(0xFF33CFFF),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  "Profile Information",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField("Full Name", _fullNameController, Icons.person_outline),
            _buildTextField("Email Address", _emailController, Icons.email_outlined),
            _buildTextField("Company", _companyController, Icons.business_outlined),
            _buildTextField("Phone", _phoneController, Icons.phone_outlined),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _updateProfile,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, 
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? "Updating..." : "Update Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF1EC0),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: const Color(0xFFFF1EC0).withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesCard() {
    return DashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Color(0xFF33CFFF),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  "Account Preferences",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Notifications",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildCheckboxTile(
              "Project updates", 
              projectUpdates, 
              Icons.work_outline,
              (value) {
                setState(() {
                  projectUpdates = value ?? false;
                });
              }
            ),
            _buildCheckboxTile(
              "New messages", 
              newMessages, 
              Icons.message_outlined,
              (value) {
                setState(() {
                  newMessages = value ?? false;
                });
              }
            ),
            _buildCheckboxTile(
              "Weekly reports", 
              weeklyReports, 
              Icons.analytics_outlined,
              (value) {
                setState(() {
                  weeklyReports = value ?? false;
                });
              }
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _updateNotificationPreferences,
                icon: _isSaving 
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2, 
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(_isSaving ? "Saving..." : "Save Preferences"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF33CFFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: const Color(0xFF33CFFF).withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return DashboardCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.logout,
                  color: Colors.red[400],
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  "Account Actions",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Sign out of your account and return to the login screen.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _showLogoutDialog,
                          icon: const Icon(Icons.logout),
                          label: const Text("Logout"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24, 
                              vertical: 12
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
                
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        "Sign out of your account and return to the login screen.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24, 
                          vertical: 12
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter $label",
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
              filled: true,
              fillColor: const Color(0xFF151229),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: Color(0xFF33CFFF)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red[400]!),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: label.toLowerCase().contains('email') 
              ? TextInputType.emailAddress 
              : label.toLowerCase().contains('phone')
                ? TextInputType.phone
                : TextInputType.text,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, IconData icon, Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151229),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFFF1EC0),
            activeTrackColor: const Color(0xFFFF1EC0).withOpacity(0.3),
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF262047),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.logout,
                color: Colors.red[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Confirm Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to logout? You will need to sign in again to access your dashboard.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _performLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout() async {
    if (!mounted) return;
    
    Navigator.of(context).pop();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            color: Color(0xFF262047),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF1EC0)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Signing out...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      await _authService.signOut();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        _showErrorMessage("Logout failed: ${e.toString()}");
      }
    }
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}