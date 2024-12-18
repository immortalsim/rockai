import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  
  runApp(RockAIApp(isLoggedIn: isLoggedIn));
}

class RockAIApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const RockAIApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RockAI',
      theme: ThemeData(
        primaryColor: const Color(0xFF808080),
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.grey)
            .copyWith(secondary: const Color(0xFFB19CD9)),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
        fontFamily: 'Roboto',
      ),
      home: isLoggedIn ? HomeScreen() : LoginScreen(),
    );
  }
}