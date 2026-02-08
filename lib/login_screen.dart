import 'package:flutter/material.dart';

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
                _loginButton(),
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
      decoration: const InputDecoration(
        labelText: 'Username',
        border: const OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
      ),
      validator: (value) {
        // Trim gets rid of white sapces
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your usernamae';
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

  void _submitLogin() {
    // Calls all of the validator function in the Form
    // I am certain currentState is not going to be null
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logging in user $username (password length: ${password.length}) ')),
      );
    }
  }
}
