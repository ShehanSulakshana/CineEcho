import 'package:cine_echo/screens/auth/forgot_password_screen.dart';
import 'package:cine_echo/screens/auth/signup_screen.dart';
import 'package:cine_echo/screens/home_screen.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:cine_echo/providers/auth_provider.dart' as auth_provider;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum FieldType { email, password, text }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUserWithEmailPassword() async {
    try {
      final authProvider = Provider.of<auth_provider.AuthenticationProvider>(
        context,
        listen: false,
      );
      await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;

      _showSnackBar("Welcome back! Signed in successfully.", Colors.green);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'An error occurred';
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many failed attempts. Try again later';
          break;
        case 'invalid-credential':
          message = 'Invalid email or password';
          break;
      }
      _showSnackBar(message, Colors.red);
    } catch (e) {
      _showSnackBar('An unexpected error occurred', Colors.red);
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          controller: ScrollController(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 70),
                Text(
                  "Welcome back!",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  "Glad to see you, Again!",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                SizedBox(height: 35),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
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
                              color: ashColor,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: Theme.of(context).textTheme.titleSmall,
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
                              _showLoadingDialog('Signing in...');
                              await loginUserWithEmailPassword();
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
                            "Log in",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                Row(
                  children: [
                    Expanded(child: Container(height: 1, color: ashColor)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Or Login with',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    Expanded(child: Container(height: 1, color: ashColor)),
                  ],
                ),

                SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.g_mobiledata_rounded),
                    label: Text(
                      'Continue with Google',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    style: ElevatedButton.styleFrom(
                      iconSize: 35,
                      backgroundColor: Theme.of(
                        context,
                      ).scaffoldBackgroundColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1, color: lightblueColor),
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        final authProvider =
                            Provider.of<auth_provider.AuthenticationProvider>(
                              context,
                              listen: false,
                            );
                        final credential = await authProvider
                            .signInWithGoogle();

                        if (credential != null) {
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
                        }
                      } on FirebaseAuthException catch (e) {
                        _showSnackBar(
                          e.message ?? 'Google Sign-In failed',
                          Colors.red,
                        );
                      } catch (e) {
                        _showSnackBar(
                          'An error occurred during Google Sign-In',
                          Colors.red,
                        );
                      }
                    },
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
                        "Don't have an account?",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          " Register Now",
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
      ),
    );
  }
}
