import 'package:datvexe_app/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'Đặt vé xe',
      theme: ThemeData(primarySwatch: Colors.blue),

      // 🟢 Bổ sung để DatePicker và các thành phần Material có thể hiển thị tiếng Việt
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // 🇻🇳 Tiếng Việt
      ],
      locale: const Locale('vi', 'VN'),

      // Màn hình đầu tiên (login)
      home: const LoginScreen(),
    );
  }
}
