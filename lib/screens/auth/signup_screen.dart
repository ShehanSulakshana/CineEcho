import 'package:flutter/material.dart';

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
                      if (value == null || value.isEmpty)
                        return 'Username required';
                      if (value.length < 3)
                        return 'Username must be 3+ characters';
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

                  // Password
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
                      if (value == null || value.isEmpty)
                        return 'Confirm password';
                      if (value != _passwordController.text)
                        return "Passwords don't match";
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final username = _usernameController.text.trim();
                          final email = _emailController.text.trim();
                          final password = _passwordController.text;

                          debugPrint('=== CineEcho Register ===');
                          debugPrint('Username: $username');
                          debugPrint('Email: $email');
                          debugPrint('Password: $password');

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Register: $username'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // TODO: FirebaseAuth.createUserWithEmailAndPassword
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
                ],
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
                        "Already have an account?",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to Login
                          Navigator.pop(context); // Back to login
                        },
                        child: Text(
                          " Login Now",
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
