import 'package:flutter/material.dart';
import 'package:responsive_design/auth_service.dart';
import 'package:responsive_design/profile_card.dart';
import 'package:responsive_design/signUp_screen.dart'; 

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _passHidden = true;

  // There could be multiple forms. this assigns a unique key to each form.
  // Also, it calls validator function for each field in the form
  final _formKey = GlobalKey<FormState>();

  // Object used for extracting data from fields
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // Spinning circle feedback
  final _authService = AuthService();

  // Dispose of controllers 
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Form(
            // Creating a form
            key: _formKey, // ID for a particular form
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: 40),
                _username(),
                const SizedBox(height: 20),
                _password(),
                const SizedBox(height: 20),
                // Show spinning circle while logging in
                _isLoading ? const CircularProgressIndicator() : _loginButton(), 
                const SizedBox(height: 12),
                _signupButton(),
              ],
            ),
          ),
        ),
      ),
    );
  } // build

  Widget _header() {
    return const Text(
      'Welcome Back',
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  // Username
  Widget _username() {
    return TextFormField(
      controller: _usernameController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Username (Email)',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        // Trim gets rid of white sapces
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your email';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  // Password
  Widget _password() {
    return TextFormField(
      // Allows to see text typed
      controller: _passwordController,
      obscureText: _passHidden,
      decoration: InputDecoration(
        labelText: 'Password',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _passHidden = !_passHidden;
            });
          },
          icon: Icon(_passHidden ? Icons.visibility_off : Icons.visibility),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        // Length of password has to be at least 8 characters
        if (value.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget _loginButton() {
    return ElevatedButton(
      onPressed: _submitLogin,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: const Text('Login'),
    );
  }

  Widget _signupButton() {
    return OutlinedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
              builder: (_) => const SignUpScreen()),
        );
      },
      child: const Text('Create an account'),
    );
  }

  void _submitLogin() async {
    // Calls all of the validator function in the Form
    // I am certain currentState is not going to be null
    if (!_formKey.currentState!.validate()) return;

    // Start spinning the progress indicator
    setState(() => _isLoading = true);

    final email = _usernameController.text;
    final password = _passwordController.text;

    try {
      await _authService.signIn(email: email, password: password);

      // From the inherited state, we can check to make sure the signing widget is still on screen
      if (!mounted) return; // TODO signOut

      // If successful, goes back to Profile Card
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProfileCard()),
      );
    } catch (e) {
      if (!mounted) return; // TODO error popup

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) { // Stop the spinning widget 
        setState(() => _isLoading = false); 
      }
    }
  }
}
