import 'dart:math';
import 'package:flutter/material.dart';
import 'package:golphin_app/pages/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golphin_app/pages/login.dart';

class ReceptionPage extends StatefulWidget {
  const ReceptionPage({super.key});

  @override
  State<ReceptionPage> createState() => _ReceptionPageState();
}

class _ReceptionPageState extends State<ReceptionPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogged = prefs.getBool('isLogged') ?? false;
    await Future.delayed(const Duration(seconds: 2));
    if (isLogged) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ChatPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return backgroundBuilder();
  }
}

Scaffold backgroundBuilder() {
  return Scaffold(
    body: Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
      child: Stack(
        children: [
          Positioned(
            bottom: 0, 
            left: 0,
            right: 0, 
            child: Image.asset(
              'assets/images/waves.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 80, 
            left: 0,
            right: 0, 
            child: Transform.rotate(
              angle: -pi / 20,
              child: Image.asset(
                'assets/images/dolphin.png',
                fit: BoxFit.cover,
                width: 400,
              ),
            ),
          ),
          Positioned(
            top: 200, 
            left: 0,
            right: 0, 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Golphin',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w300,
                    color: Colors.teal[200],
                  ),
                ),
                const Text(
                  'SOLUTIONS',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),                  
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
