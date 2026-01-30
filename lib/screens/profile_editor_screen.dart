import 'dart:io';

import 'package:cine_echo/providers/auth_provider.dart';
import 'package:cine_echo/screens/onboard_screen.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ProfileEditorScreen extends StatefulWidget {
  const ProfileEditorScreen({super.key});

  @override
  State<ProfileEditorScreen> createState() => _ProfileEditorScreenState();
}

class _ProfileEditorScreenState extends State<ProfileEditorScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _aboutController;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _aboutController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authProvider = Provider.of<AuthenticationProvider>(
      context,
      listen: false,
    );
    final user = authProvider.currentUser;

    if (user != null) {
      _usernameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      final profile = await authProvider.fetchUserProfile(user.uid);
      if (profile != null) {
        _aboutController.text = profile['about'] ?? '';
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        _showSnackBar('Image selected successfully', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Failed to pick image', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_usernameController.text.isEmpty) {
      _showSnackBar('Username cannot be empty', Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthenticationProvider>(
        context,
        listen: false,
      );

      final username = _usernameController.text.trim();
      await authProvider.updateUserName(username: username);

      final user = authProvider.currentUser;
      if (user != null) {
        await authProvider.saveUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          displayName: username,
          about: _aboutController.text.trim(),
        );
      }

      _showSnackBar('Profile updated successfully', Colors.green);

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      _showSnackBar('Failed to save changes', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Logout',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              _performLogout();
            },
            child: Text(
              'Logout',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.red.shade400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthenticationProvider>(
        context,
        listen: false,
      );

      await authProvider.signOut();
      await authProvider.signOutGoogle();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OnboardScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showSnackBar('Logout failed: ${e.toString()}', Colors.red);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: navActive),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: 0.8 + (0.2 * value),
                          child: child,
                        ),
                      );
                    },
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withAlpha(220),
                                  blurRadius: 8,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 75,
                              backgroundColor: navNonActive,
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : const AssetImage('assets/splash/logo.png')
                                        as ImageProvider,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(120),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to change photo',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 40),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        _buildEditField(
                          label: 'Username',
                          controller: _usernameController,
                          icon: Icons.person_outline,
                          readOnly: false,
                        ),
                        const SizedBox(height: 18),
                        _buildEditField(
                          label: 'Email',
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          readOnly: true,
                        ),
                        const SizedBox(height: 18),
                        _buildEditField(
                          label: 'About',
                          controller: _aboutController,
                          icon: Icons.info_outline,
                          readOnly: false,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveChanges,
                            icon: _isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.check_circle_outline,
                                    size: 22,
                                  ),
                            label: Text(
                              _isLoading ? 'Saving...' : 'Save Changes',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              disabledBackgroundColor: Colors.grey[600],
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shadowColor: Theme.of(
                                context,
                              ).primaryColor.withAlpha(180),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              size: 22,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Cancel',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(
                                color: Colors.grey.withAlpha(180),
                                width: 1.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Divider(
                          color: Colors.grey.withAlpha(100),
                          thickness: 1.2,
                          height: 40,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _logout,
                            icon: const Icon(Icons.logout_rounded, size: 22),
                            label: Text(
                              'Logout',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[600],
                              elevation: 4,
                              shadowColor: Colors.red.withAlpha(150),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool readOnly,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withAlpha(160), width: 1.6),
            color: readOnly
                ? Colors.grey.withAlpha(25)
                : Colors.grey.withAlpha(45),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            maxLines: maxLines ?? 1,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: navActive, size: 22),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              hintText: 'Enter $label',
              hintStyle: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white38),
            ),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: readOnly ? Colors.white54 : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
