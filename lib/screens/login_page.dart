// ignore_for_file: use_build_context_synchronously, unused_import

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
  bool _showHint = false;
  String _hintText = '';
  bool _isLoading = false;

  late AnimationController _pulseController;

  final Map<String, String> _correctPasswords = {
    'client': 'client123',
    'freelancer': 'free123',
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(String? value) {
    setState(() {
      _selectedRole = value;
      if (value == 'client') {
        _hintText = 'Client password: client123';
        _showHint = true;
      } else if (value == 'freelancer') {
        _hintText = 'Freelancer password: free123';
        _showHint = true;
      } else {
        _showHint = false;
      }
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRole == null || _selectedRole!.isEmpty) {
      _showSnackBar('Please select your role');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final passwordText = _passwordController.text.trim();
      final usernameText = _usernameController.text.trim();
      final expectedPassword = _correctPasswords[_selectedRole!];

      if (passwordText == expectedPassword) {
        // Use Firebase authentication
        try {
          await AuthService().signInWithCredentials(
            usernameText,
            passwordText,
            _selectedRole!,
          );

          _showSnackBar(
            'Welcome, $usernameText! Login successful.',
            isSuccess: true,
          );

          // Navigate to appropriate dashboard based on role
          if (mounted) {
            if (_selectedRole == 'client') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const DashboardScreen()),
              );
            } else if (_selectedRole == 'freelancer') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            }
          }
        } catch (authError) {
          if (mounted) {
            _showSnackBar('Authentication failed: ${authError.toString()}');
          }
        }
      } else {
        if (mounted) {
          _pulseController.forward().then((_) {
            if (mounted) {
              _pulseController.reverse();
            }
          });
          _showSnackBar('Incorrect password. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Login failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isSuccess ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1B1737), Color(0xFF1E1A3C), Color(0xFF2A1B5C)],
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
                                  _buildRoleSelector(),
                                  const SizedBox(height: 24),
                                  _buildUsernameField(),
                                  const SizedBox(height: 24),
                                  _buildPasswordField(),
                                  const SizedBox(height: 32),
                                  _buildLoginButton(),
                                  const SizedBox(height: 24),
                                  _buildHelpLink(),
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
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C33FF), Color(0xFF33CFFF)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(40)),
          ),
          child: const Icon(Icons.laptop_mac, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        const Text(
          'FreelanceHub',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 64,
          height: 4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C33FF), Color(0xFF33CFFF)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
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
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.people, color: Color(0xFF33CFFF), size: 32),
              Icon(Icons.handshake, color: Color(0xFF33CFFF), size: 32),
              Icon(Icons.rocket_launch, color: Color(0xFF33CFFF), size: 32),
            ],
          ),
          SizedBox(height: 12),
          Text(
            'Welcome to Freelancer App',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Connect. Create. Collaborate.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: Color(0xFF33CFFF),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C33FF), Color(0xFF33CFFF)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
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
              dropdownColor: const Color(0xFF424242),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'client', child: Text('Client')),
                DropdownMenuItem(
                  value: 'freelancer',
                  child: Text('Freelancer'),
                ),
              ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_circle_outlined,
                color: Color(0xFF33CFFF), size: 18),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C33FF), Color(0xFF33CFFF)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
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
                hintText: 'Enter your username',
                hintStyle: TextStyle(color: Colors.grey),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your username';
                }
                if (value.trim().length < 3) {
                  return 'Username must be at least 3 characters';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF33CFFF), size: 18),
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8C33FF), Color(0xFF33CFFF)],
            ),
            borderRadius: BorderRadius.all(Radius.circular(12)),
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
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: _showHint ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[400], size: 14),
                const SizedBox(width: 4),
                Text(
                  _hintText,
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B1737), Color(0xFF1E1A3C), Color(0xFF2A1B5C)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF1EC0).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: const Color.fromARGB(0, 5, 5, 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.login, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Login',
                    style: TextStyle(
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

  Widget _buildHelpLink() {
    return GestureDetector(
      onTap: () {
        _showSnackBar('Help feature coming soon!');
      },
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.help_outline, color: Color(0xFF33CFFF), size: 16),
          SizedBox(width: 4),
          Text(
            'Need help?',
            style: TextStyle(fontSize: 14, color: Color(0xFF33CFFF)),
          ),
        ],
      ),
    );
  }
}
