import 'package:cine_echo/screens/auth/login_screen.dart';
import 'package:cine_echo/screens/home_screen.dart';
import 'package:cine_echo/providers/auth_provider.dart' as auth_provider;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> createUserWithEmailAndPassword() async {
    try {
      final authProvider = Provider.of<auth_provider.AuthenticationProvider>(
        context,
        listen: false,
      );

      // Create the account
      final credential = await authProvider.createAccount(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Update the display name with username
      final username = _usernameController.text.trim();
      await authProvider.updateUserName(
        username: _usernameController.text.trim(),
      );

      final uid = credential.user?.uid;
      final email = _emailController.text.trim();
      if (uid != null) {
        await authProvider.saveUserProfile(
          uid: uid,
          email: email,
          displayName: username,
        );
      }

      if (!mounted) return;

      _showSnackBar(
        "Account created successfully! Welcome aboard.",
        Colors.green,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'An error occurred';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use a stronger password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'operation-not-allowed':
          message = 'Email/password accounts are not enabled';
          break;
      }
      _showSnackBar(message, Colors.red);
    } catch (e) {
      _showSnackBar(
        'An unexpected error occurred: ${e.toString()}',
        Colors.red,
      );
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color.fromARGB(255, 15, 35, 50),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 20),
                Text(message, style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: ScrollController(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 120),
              Text(
                "Create Account",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                "Join CineEcho today!",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 35),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Username
                    TextFormField(
                      controller: _usernameController,
                      cursorColor: Theme.of(context).primaryColor,
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.bodySmall,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Username required';
                        }
                        if (value.length < 3) {
                          return 'Username must be 3+ characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Username',
                        fillColor: Theme.of(
                          context,
                        ).inputDecorationTheme.fillColor,
                        labelStyle: Theme.of(
                          context,
                        ).inputDecorationTheme.labelStyle,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorStyle: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Theme.of(context).primaryColor,
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.bodySmall,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email required';
                        }
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        fillColor: Theme.of(
                          context,
                        ).inputDecorationTheme.fillColor,
                        labelStyle: Theme.of(
                          context,
                        ).inputDecorationTheme.labelStyle,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorStyle: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor: Theme.of(context).primaryColor,
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.bodySmall,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password required';
                        }
                        if (value.length < 8) {
                          return 'Password must be 8+ characters';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Password',
                        fillColor: Theme.of(
                          context,
                        ).inputDecorationTheme.fillColor,
                        labelStyle: Theme.of(
                          context,
                        ).inputDecorationTheme.labelStyle,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorStyle: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Confirm Password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      keyboardType: TextInputType.visiblePassword,
                      cursorColor: Theme.of(context).primaryColor,
                      textAlignVertical: TextAlignVertical.center,
                      style: Theme.of(context).textTheme.bodySmall,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirm password';
                        }
                        if (value != _passwordController.text) {
                          return "Passwords don't match";
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        fillColor: Theme.of(
                          context,
                        ).inputDecorationTheme.fillColor,
                        labelStyle: Theme.of(
                          context,
                        ).inputDecorationTheme.labelStyle,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorStyle: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 12,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _showLoadingDialog('Creating account...');
                            await createUserWithEmailAndPassword();
                            // ignore: use_build_context_synchronously
                            if (mounted) Navigator.of(context).pop();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                        child: Text(
                          "Sign Up",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Divider with "OR"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "OR",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Google Sign-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 65,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            final authProvider =
                                Provider.of<
                                  auth_provider.AuthenticationProvider
                                >(context, listen: false);
                            await authProvider.signInWithGoogle();

                            if (!mounted) return;

                            _showSnackBar(
                              "Signed in with Google successfully!",
                              Colors.green,
                            );
                            Navigator.pushAndRemoveUntil(
                              // ignore: use_build_context_synchronously
                              context,
                              MaterialPageRoute(builder: (_) => HomeScreen()),
                              (route) => false,
                            );
                          } on FirebaseAuthException catch (e) {
                            String message =
                                e.message ?? 'Google Sign-In failed';
                            switch (e.code) {
                              case 'account-exists-with-different-credential':
                                message =
                                    'An account already exists with the same email';
                                break;
                              case 'invalid-credential':
                                message = 'The credential is invalid';
                                break;
                              case 'operation-not-allowed':
                                message = 'Google Sign-In is not enabled';
                                break;
                              case 'user-disabled':
                                message = 'This account has been disabled';
                                break;
                            }
                            _showSnackBar(message, Colors.red);
                          } catch (e) {
                            _showSnackBar(
                              'An unexpected error occurred with Google Sign-In',
                              Colors.red,
                            );
                          }
                        },
                        icon: Image.asset(
                          'assets/images/google_logo.png',
                          height: 24,
                          width: 24,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.login, size: 24);
                          },
                        ),
                        label: Text(
                          "Continue with Google",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        " Login Now",
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
