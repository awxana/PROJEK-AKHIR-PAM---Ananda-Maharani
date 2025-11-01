import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'package:projectakhir_mobile/Models/user.dart';
import 'package:projectakhir_mobile/Views/login_screen.dart';
import 'package:projectakhir_mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formfield = GlobalKey<FormState>();
  bool passToggle = true;

  late SharedPreferences prefs;
  late Box<UserModel> _myBox;

  // Warna feminim seperti dashboard & login
  static const Color pink = Color(0xFFFF8FAB);
  static const Color dark = Color(0xFF201628);
  static const Color card = Color(0xFF2A1E37);
  static const Color text = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    initPrefs();
    _myBox = Hive.box(boxName);
  }

  void initPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'ValorantFont',
          ),
        ),
        backgroundColor: pink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _register() async {
    if (_formfield.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      // Cek apakah username sudah terdaftar
      bool exists = false;
      for (int i = 0; i < _myBox.length; i++) {
        if (_myBox.getAt(i)!.username == username) {
          exists = true;
          break;
        }
      }

      if (exists) {
        _showSnackbar('Username already exists 💢');
      } else {
        final hashedPassword = sha256.convert(utf8.encode(password)).toString();
        _myBox.add(UserModel(username: username, password: hashedPassword));
        _showSnackbar('Registration Successful 💕');
        await prefs.remove("username");
        _goToLogin();
      }
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: dark,
      body: Stack(
        children: [
          // Background image lembut
          Positioned.fill(
            child: Image.asset(
              'assets/valobackground.jpg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.15),
            ),
          ),

          // Overlay gradasi ungu gelap
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dark.withOpacity(0.3),
                  dark.withOpacity(0.9),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
              child: Form(
                key: _formfield,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo + Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/valorant-logo.png',
                          height: 60,
                          color: pink,
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "REGISTER",
                          style: TextStyle(
                            fontFamily: 'ValorantFont',
                            fontSize: 30,
                            color: text,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),

                    // USERNAME FIELD
                    Container(
                      decoration: BoxDecoration(
                        color: card.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: pink.withOpacity(0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: pink.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.name,
                        controller: _usernameController,
                        style: const TextStyle(
                          color: text,
                          fontFamily: 'ValorantFont',
                        ),
                        decoration: InputDecoration(
                          labelText: "USERNAME",
                          labelStyle: TextStyle(
                            color: text.withOpacity(0.6),
                            fontFamily: 'ValorantFont',
                          ),
                          prefixIcon: const Icon(Icons.person, color: pink),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PASSWORD FIELD
                    Container(
                      decoration: BoxDecoration(
                        color: card.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: pink.withOpacity(0.35)),
                        boxShadow: [
                          BoxShadow(
                            color: pink.withOpacity(0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: _passwordController,
                        obscureText: passToggle,
                        style: const TextStyle(
                          color: text,
                          fontFamily: 'ValorantFont',
                        ),
                        decoration: InputDecoration(
                          labelText: "PASSWORD",
                          labelStyle: TextStyle(
                            color: text.withOpacity(0.6),
                            fontFamily: 'ValorantFont',
                          ),
                          prefixIcon: const Icon(Icons.lock, color: pink),
                          suffixIcon: InkWell(
                            onTap: () {
                              setState(() {
                                passToggle = !passToggle;
                              });
                            },
                            child: Icon(
                              passToggle
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: text.withOpacity(0.6),
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 18),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 50),

                    // REGISTER BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pink,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "REGISTER",
                          style: TextStyle(
                            fontFamily: 'ValorantFont',
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Back to login
                    TextButton(
                      onPressed: _goToLogin,
                      child: const Text(
                        "Already have an account? Login here.",
                        style: TextStyle(
                          fontFamily: 'ValorantFont',
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
