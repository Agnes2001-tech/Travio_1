import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../theme/app_colors.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

  void _login() {
    Fluttertoast.showToast(msg: 'Login successful!');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              const SizedBox(height: 16),
              const Text(
                'Welcome Back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to manage your luxury flights and hotel stays.',
                style: TextStyle(color: AppColors.textGrey),
              ),
              const SizedBox(height: 32),
              const Text(
                'Email Address',
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: 'name@example.com'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () =>
                        Fluttertoast.showToast(msg: 'Reset link sent!'),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(color: AppColors.primary, fontSize: 12),
                    ),
                  ),
                ],
              ),
              TextField(
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              _socialBtn('G', 'Continue with Google'),
              const SizedBox(height: 12),
              _socialBtn('', 'Continue with Apple', isApple: true),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () => Fluttertoast.showToast(msg: 'Sign Up tapped!'),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialBtn(String label, String text, {bool isApple = false}) {
    return OutlinedButton(
      onPressed: () => Fluttertoast.showToast(msg: '$text tapped!'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isApple
              ? const Icon(Icons.apple, size: 20)
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(color: AppColors.textDark)),
        ],
      ),
    );
  }
}
