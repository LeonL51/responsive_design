import 'package:flutter/material.dart';
import 'package:responsive_design/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passHidden = true;
  bool _isLoading = false;

  final _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    final hasLower = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    final hasSymbol = RegExp(r'[^\w\s]').hasMatch(value);

    if (!hasUpper) return 'Must contain at least 1 uppercase letter';
    if (!hasLower) return 'Must contain at least 1 lowercase letter';
    if (!hasDigit) return 'Must contain at least 1 digit';
    if (!hasSymbol) return 'Must contain at least 1 symbol';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Create Account',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Username (Email)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@') ||
                      !value.contains('.')) {
                    return 'Please enter valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: _passHidden,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => setState(
                        () => _passHidden = !_passHidden),
                    icon: Icon(_passHidden
                        ? Icons.visibility_off
                        : Icons.visibility),
                  ),
                ),
                validator: _validatePassword, 
              ),

              const SizedBox(height: 20),

              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitSignUp,
                      child:
                          const Text('Create Account'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      await _authService.signUp(
          email: email, password: password);

      if (!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Account created! Please log in.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final msg =
          e.toString().replaceFirst('Exception: ', '');

      if (msg == 'ACCOUNT_EXISTS') {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Account already exists. Please log in.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted)
        setState(() => _isLoading = false);
    }
  }
}
