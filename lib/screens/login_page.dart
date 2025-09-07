// ignore_for_file: use_build_context_synchronously, avoid_print, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart' show UserCredential;
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'package:freelance_hub/freelan/home_page.dart';
import 'package:freelance_hub/service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedRole;
  bool _passwordVisible = false;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isDemoMode = false;

  late AnimationController _pulseController;
  late AnimationController _errorController;

  // Dynamic configuration
  final Map<String, dynamic> _appConfig = {
    'appName': 'FreelanceHub',
    'appDescription': 'Connect. Create. Collaborate.',
    'enableDemoMode': true,
    'roles': [
      {
        'id': 'client',
        'name': 'Client',
        'icon': Icons.business,
        'demoPassword': 'client123',
        'route': () => const DashboardScreen(),
      },
      {
        'id': 'freelancer',
        'name': 'Freelancer',
        'icon': Icons.work,
        'demoPassword': 'free123',
        'route': () => HomePage(),
      },
    ],
    'validation': {
      'minUsernameLength': 2,
      'minPasswordLength': 6,
      'requireSpecialChar': false,
      'requireNumber': false,
    },
    'theme': {
      'primaryGradient': [Color(0xFF8C33FF), Color(0xFF33CFFF)],
      'backgroundGradient': [Color(0xFF1B1737), Color(0xFF1E1A3C), Color(0xFF2A1B5C)],
      'cardColor': Color(0xFF2A1B5C),
      'accentColor': Color(0xFF33CFFF),
    }
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _errorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _isDemoMode = _appConfig['enableDemoMode'] ?? false;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _errorController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(String? value) {
    setState(() {
      _selectedRole = value;
      _errorMessage = '';
      
      if (_isDemoMode && value != null) {
        final role = _getRoleConfig(value);
        if (role != null) {
          _passwordController.text = role['demoPassword'] ?? '';
        }
      }
    });
  }

  Map<String, dynamic>? _getRoleConfig(String roleId) {
    final roles = _appConfig['roles'] as List<Map<String, dynamic>>;
    return roles.firstWhere(
      (role) => role['id'] == roleId,
      orElse: () => {},
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _toggleDemoMode() {
    setState(() {
      _isDemoMode = !_isDemoMode;
      if (!_isDemoMode) {
        _passwordController.clear();
      } else if (_selectedRole != null) {
        final role = _getRoleConfig(_selectedRole!);
        if (role != null) {
          _passwordController.text = role['demoPassword'] ?? '';
        }
      }
    });
  }

  String? _validateUsername(String? value) {
    final validation = _appConfig['validation'] as Map<String, dynamic>;
    
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your username';
    }
    
    final minLength = validation['minUsernameLength'] ?? 2;
    if (value.trim().length < minLength) {
      return 'Username must be at least $minLength characters';
    }
    
    // Add more validation rules as needed
    if (value.contains('@') && !_isValidEmail(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  String? _validatePassword(String? value) {
    final validation = _appConfig['validation'] as Map<String, dynamic>;
    
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your password';
    }
    
    final minLength = validation['minPasswordLength'] ?? 6;
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    
    if (validation['requireNumber'] == true && !value.contains(RegExp(r'\d'))) {
      return 'Password must contain at least one number';
    }
    
    if (validation['requireSpecialChar'] == true && 
        !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = '';
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null || _selectedRole!.isEmpty) {
      _showError('Please select your role');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final passwordText = _passwordController.text.trim();
      final usernameText = _usernameController.text.trim();

      print('🔄 Attempting login with:');
      print('Username: $usernameText');
      print('Role: $_selectedRole');

      UserCredential? result;

      if (_isDemoMode) {
        // Demo mode authentication
        final role = _getRoleConfig(_selectedRole!);
        if (role != null && passwordText == role['demoPassword']) {
          result = await AuthService().signInDemo(usernameText, _selectedRole!);
        } else {
          throw Exception('Invalid demo credentials');
        }
      } else {
        // Real authentication
        result = await AuthService().signInWithCredentials(
          usernameText,
          passwordText,
          _selectedRole!,
        );
      }

      if (result != null && result.user != null) {
        if (mounted) {
          _showSnackBar(
            'Welcome, $usernameText! Login successful.',
            isSuccess: true,
          );

          await Future.delayed(const Duration(milliseconds: 500));

          // Dynamic navigation based on role configuration
          final roleConfig = _getRoleConfig(_selectedRole!);
          if (roleConfig != null && roleConfig['route'] != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => roleConfig['route']()),
            );
          } else {
            throw Exception('Navigation route not configured for role: $_selectedRole');
          }
        }
      } else {
        throw Exception('Login failed - no user returned');
      }
    } catch (e) {
      print('❌ Login error: $e');
      if (mounted) {
        _showError(e.toString().replaceFirst('Exception: ', ''));
        _pulseController.forward().then((_) {
          if (mounted) {
            _pulseController.reverse();
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    _errorController.forward().then((_) {
      if (mounted) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            _errorController.reverse();
            setState(() {
              _errorMessage = '';
            });
          }
        });
      }
    });
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: isSuccess ? Colors.green[600] : Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: Duration(seconds: isSuccess ? 2 : 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _appConfig['theme'] as Map<String, dynamic>;
    final backgroundGradient = theme['backgroundGradient'] as List<Color>;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: backgroundGradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: SingleChildScrollView(
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1.0 + (_pulseController.value * 0.05),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Card(
                          elevation: 25,
                          color: Colors.grey[900]!.withOpacity(0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 32),
                                  _buildWelcomeSection(),
                                  const SizedBox(height: 32),
                                  _buildDemoModeToggle(),
                                  const SizedBox(height: 16),
                                  _buildRoleSelector(),
                                  const SizedBox(height: 24),
                                  _buildUsernameField(),
                                  const SizedBox(height: 24),
                                  _buildPasswordField(),
                                  if (_errorMessage.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    _buildErrorMessage(),
                                  ],
                                  const SizedBox(height: 32),
                                  _buildLoginButton(),
                                  const SizedBox(height: 24),
                                  if (_isDemoMode) _buildDemoInfo(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = _appConfig['theme'] as Map<String, dynamic>;
    final primaryGradient = theme['primaryGradient'] as List<Color>;
    final appName = _appConfig['appName'] as String;
    
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: primaryGradient),
            borderRadius: const BorderRadius.all(Radius.circular(40)),
          ),
          child: const Icon(Icons.laptop_mac, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          appName,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 64,
          height: 4,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: primaryGradient),
            borderRadius: const BorderRadius.all(Radius.circular(2)),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final appDescription = _appConfig['appDescription'] as String;
    final theme = _appConfig['theme'] as Map<String, dynamic>;
    final accentColor = theme['accentColor'] as Color;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6B21A8).withOpacity(0.8),
            const Color(0xFF1E3A8A).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.people, color: accentColor, size: 32),
              Icon(Icons.handshake, color: accentColor, size: 32),
              Icon(Icons.rocket_launch, color: accentColor, size: 32),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Welcome to Freelancer App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appDescription,
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoModeToggle() {
    if (!(_appConfig['enableDemoMode'] ?? false)) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Demo Mode',
          style: TextStyle(
            color: Colors.grey[300],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: _isDemoMode,
          onChanged: (value) => _toggleDemoMode(),
          activeColor: const Color(0xFF33CFFF),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    final roles = _appConfig['roles'] as List<Map<String, dynamic>>;
    final theme = _appConfig['theme'] as Map<String, dynamic>;
    final primaryGradient = theme['primaryGradient'] as List<Color>;
    final accentColor = theme['accentColor'] as Color;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.person_outline,
              color: accentColor,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Select Your Role',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: primaryGradient),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1A3C),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              hint: const Text(
                'Choose your role...',
                style: TextStyle(color: Colors.grey),
              ),
              dropdownColor: const Color(0xFF2A1B5C),
              style: const TextStyle(color: Colors.white),
              items: roles.map<DropdownMenuItem<String>>((role) {
                return DropdownMenuItem<String>(
                  value: role['id'],
                  child: Row(
                    children: [
                      Icon(role['icon'], color: accentColor, size: 16),
                      const SizedBox(width: 8),
                      Text(role['name']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _onRoleChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your role';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    final theme = _appConfig['theme'] as Map<String, dynamic>;
    final primaryGradient = theme['primaryGradient'] as List<Color>;
    final accentColor = theme['accentColor'] as Color;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_circle_outlined, color: accentColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'Username',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: primaryGradient),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1A3C),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: TextFormField(
              controller: _usernameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Enter your username or email',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              validator: _validateUsername,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    final theme = _appConfig['theme'] as Map<String, dynamic>;
    final primaryGradient = theme['primaryGradient'] as List<Color>;
    final accentColor = theme['accentColor'] as Color;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.lock_outline, color: accentColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'Password',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[300],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: primaryGradient),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1E1A3C),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                hintText: 'Enter your password',
                hintStyle: const TextStyle(color: Colors.grey),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              validator: _validatePassword,
            ),
          ),
        ),
        if (_isDemoMode && _selectedRole != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[400], size: 14),
              const SizedBox(width: 4),
              Text(
                'Demo password: ${_getRoleConfig(_selectedRole!)!['demoPassword']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildErrorMessage() {
    return AnimatedBuilder(
      animation: _errorController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_errorController.value * 0.2),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[600]?.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[400]!, width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton() {
    final theme = _appConfig['theme'] as Map<String, dynamic>;
    final primaryGradient = theme['primaryGradient'] as List<Color>;
    
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: primaryGradient),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryGradient.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Signing in...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDemoMode ? Icons.play_arrow : Icons.login,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isDemoMode ? 'Demo Login' : 'Login',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDemoInfo() {
    final roles = _appConfig['roles'] as List<Map<String, dynamic>>;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A1B5C).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF33CFFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF33CFFF), size: 16),
              const SizedBox(width: 8),
              Text(
                'Demo Credentials',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...roles.map((role) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${role['name']}: Any username + "${role['demoPassword']}"',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
                height: 1.4,
              ),
            ),
          )),
        ],
      ),
    );
  }
}