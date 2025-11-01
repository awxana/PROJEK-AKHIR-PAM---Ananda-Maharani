import 'package:flutter/material.dart';
import 'package:projectakhir_mobile/Models/user.dart';
import 'package:projectakhir_mobile/Views/dashboard.dart';
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:projectakhir_mobile/main.dart';
import 'package:projectakhir_mobile/Views/registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formfield = GlobalKey<FormState>();
  bool passToggle = true;

  late Box<UserModel> _myBox;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    checkIsLogin();
    _myBox = Hive.box(boxName);
  }

  void checkIsLogin() async {
    prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getString('username') != null;
    if (isLogin && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const DashboardPage(),
        ),
        (route) => false,
      );
    }
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
        backgroundColor: const Color(0xFFFF8FAB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _login() async {
    if (_formfield.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      final found = checkLogin(username, hashedPassword);

      if (!found) {
        _showSnackbar('Username or Password is Wrong');
      } else {
        await prefs.setString('username', username);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const DashboardPage(),
          ),
          (route) => false,
        );
        _showSnackbar('Login Success');
      }
    }
  }

  void _goToRegister() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // warna sesuai dashboard feminim
    const Color pink = Color(0xFFFF8FAB);
    const Color dark = Color(0xFF201628);
    const Color card = Color(0xFF2A1E37);
    const Color text = Color(0xFFFFFFFF);

    return Scaffold(
      backgroundColor: dark,
      body: Stack(
        children: [
          // background image kayak dashboard
          Positioned.fill(
            child: Image.asset(
              'assets/valobackground.jpg',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.15),
            ),
          ),

          // gradient overlay biar elegan
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
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 70),
              child: Form(
                key: _formfield,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // header logo
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
                          "LOGIN AGENTS",
                          style: TextStyle(
                            fontFamily: 'ValorantFont',
                            fontSize: 28,
                            color: text,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // USERNAME
                    Container(
                      decoration: BoxDecoration(
                        color: card.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
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

                    // PASSWORD
                    Container(
                      decoration: BoxDecoration(
                        color: card.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
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

                    const SizedBox(height: 40),

                    // BUTTON LOGIN
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pink,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                            fontFamily: 'ValorantFont',
                            color: Colors.white,
                            fontSize: 17,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: _goToRegister,
                      child: const Text(
                        "Don't have an account? Register here.",
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

  int getLength() => _myBox.length;

  bool checkLogin(String username, String password) {
    bool found = false;
    for (int i = 0; i < getLength(); i++) {
      if (username == _myBox.getAt(i)!.username &&
          password == _myBox.getAt(i)!.password) {
        found = true;
        break;
      } else {
        found = false;
      }
    }
    return found;
  }

  bool checkUsers(String username) {
    bool found = false;
    for (int i = 0; i < getLength(); i++) {
      if (username == _myBox.getAt(i)!.username) {
        found = true;
        break;
      } else {
        found = false;
      }
    }
    return found;
  }
}
