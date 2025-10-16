import 'package:datvexe_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/api.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load biến môi trường
  await dotenv.load(fileName: ".env");
  await Api.loadToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đặt vé xe',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
