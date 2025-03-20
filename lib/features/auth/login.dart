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
  bool _obscureText = true;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          // Beri padding secukupnya agar tidak menempel di tepi layar
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
          // Gunakan Column biasa, tanpa scroll
          child: Column(
            // Supaya kolom penuh lebar dan bisa diatur alignment-nya
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Jarak vertikal diatur spaceEvenly agar terlihat rapi
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bagian atas (gambar, teks "Login", dll) kita bungkus lagi dengan Column
              Column(
                children: [
                  const SizedBox(height: 20),
                  // Center-kan gambar
                  Center(
                    child: Image.asset(
                      'assets/images/login_image.jpg',
                      height: 200,
                      width: 200,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Center-kan teks "Login"
                  Center(
                    child: Text(
                      "Login",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // TextField Email
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
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  const SizedBox(height: 20),

                  // TextField Password
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
                      // Password visiblity toggle icon
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscureText,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => login(),
                  ),
                  const SizedBox(height: 10),

                  // Row Remember me (start alignment)
                  Row(
                    children: [
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: Colors.blue[800],
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
                ],
              ),

              // Bagian bawah (tombol Login) di tengah
              Center(
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
                          minimumSize: const Size(400, 50),
                        ),
                        child: const Text('Login'),
                      ),
              ),
            ],
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
