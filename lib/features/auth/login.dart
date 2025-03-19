import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

class LoginScreen extends ConsumerStatefulWidget {
  static const String route = '/login';

  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _rememberMe = false;

  // Define FocusNodes for the email and password fields.
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Future<void> login() async {
    setState(() => isLoading = true);
    final authService = ref.read(authProvider);
    final response = await authService.signIn(
      emailController.text.trim(),
      passwordController.text.trim(),
    );
    setState(() => isLoading = false);

    if (response != null) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response), backgroundColor: Colors.red),
      );
    } else {
      // Navigate to the home screen after successful login
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate height minus padding to avoid keyboard or system UI conflicts.
    final double screenHeight = MediaQuery.of(context).size.height;
    final double paddingVertical = MediaQuery.of(context).padding.top + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              // Ensure the content takes up full height if possible.
              constraints: BoxConstraints(minHeight: screenHeight - paddingVertical),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const SizedBox(height: 40),
                        Image.asset(
                          'assets/images/login_image.jpg',
                          height: 220,
                          width: 220,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Login",
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 32),
                        // Email TextField with explicit focus management.
                        TextField(
                          controller: emailController,
                          focusNode: _emailFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onSubmitted: (_) {
                            // Move focus directly to the password field.
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                        ),
                        const SizedBox(height: 20),
                        // Password TextField with explicit focus management.
                        TextField(
                          controller: passwordController,
                          focusNode: _passwordFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => login(),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: _rememberMe,
                                  activeColor: Colors.black,
                                  checkColor: Colors.white,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _rememberMe = newValue ?? false;
                                    });
                                  },
                                ),
                              ),
                              Text(
                                'Remember me',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30),
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : FilledButton(
                              onPressed: login,
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(350, 50),
                              ),
                              child: const Text('Login'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SupabaseAuthService {
  final supabase = Supabase.instance.client;

  Future<String?> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null ? null : 'Login failed';
    } catch (e) {
      return e.toString();
    }
  }
}
