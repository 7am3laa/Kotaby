import 'package:flutter/material.dart';
import 'package:kotaby/UI/screens/auth%20screen/login_screen.dart';
import 'package:kotaby/UI/screens/auth%20screen/signup_screen.dart';
import 'package:kotaby/constants/constants.dart';
import 'package:kotaby/storage.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleScreen() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isWidth = MediaQuery.of(context).size.width >= 500;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Storage.themeState == 1 ? primaryColor : Colors.white,
      body: Center(
        child: SizedBox(
          width: isWidth ? width / 1.5 : width,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: _isLogin
                  ? LoginScreen(toggleScreen: () => _toggleScreen())
                  : SignupScreen(toggleScreen: () => _toggleScreen()),
            ),
          ),
        ),
      ),
    );
  }
}
