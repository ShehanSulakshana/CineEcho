import 'package:cine_echo/screens/auth/signup_screen.dart';
import 'package:cine_echo/themes/pallets.dart';
import 'package:flutter/material.dart';

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

  // Password toggle state
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        leading: IconButton(
          padding: EdgeInsets.only(left: 15),
          iconSize: 35,
          color: Colors.white,
          alignment: Alignment.center,
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  // Inline Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: Theme.of(context).primaryColor,
                    textAlignVertical: TextAlignVertical.center,
                    style: Theme.of(context).textTheme.bodySmall,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Email required';
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

                  // Inline Password Field with Toggle
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    cursorColor: Theme.of(context).primaryColor,
                    textAlignVertical: TextAlignVertical.center,
                    style: Theme.of(context).textTheme.bodySmall,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Password required';
                      if (value.length < 8)
                        return 'Password must be 8+ characters';
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
                          // TODO: Forgot Password navigation
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;

                          debugPrint('=== CineEcho Login ===');
                          debugPrint('Email: $email');
                          debugPrint('Password: $password');

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Login: $email'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // TODO: FirebaseAuth.signInWithEmailAndPassword
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
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: lightblueColor),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  // TODO: Google Sign-In
                },
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Align(
                  alignment: Alignment.bottomCenter,
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
                          // TODO: Navigate to Sign Up
                          Navigator.push(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
