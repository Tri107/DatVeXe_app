import 'package:datvexe_app/screens/common/splash_screen.dart';
import 'package:datvexe_app/screens/khachhang/home_screen.dart';
import 'package:datvexe_app/screens/taixe/taixe_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:datvexe_app/config/api.dart';
import 'package:datvexe_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:datvexe_app/models/TaiKhoan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await Api.loadToken();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Kiểm tra token và trả về user (nếu có)
  Future<TaiKhoan?> _getUserFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print('🔍 Kiểm tra token trong SharedPreferences: $token');

    if (token != null && token.isNotEmpty) {
      // Gắn lại token vào header cho API
      await Api.setToken(token);

      try {
        // Giải mã token để lấy payload
        Map<String, dynamic> decoded = JwtDecoder.decode(token);
        print('🧩 Payload token: $decoded');

        return TaiKhoan(
          sdt: decoded['sdt'] ?? '',
          role: decoded['role'] ?? 'user',
        );
      } catch (e) {
        print('⚠️ Lỗi giải mã token: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Đặt vé xe',
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN')],
      locale: const Locale('vi', 'VN'),

      home: FutureBuilder<TaiKhoan?>(
        future: _getUserFromToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasError) {
            print('❌ Lỗi khi đọc token: ${snapshot.error}');
            return const LoginScreen();
          }

          if (snapshot.data != null) {
            final user = snapshot.data!;
            print('✅ Token hợp lệ, vai trò: ${user.role}');

            // 🔀 Chuyển hướng theo role
            if (user.role == 'taixe') {
              print('🚗 Vào giao diện Tài xế');
              return TaiXeHomeScreen(user: user);
            } else {
              print('🏠 Vào giao diện Khách hàng');
              return HomeScreen(user: user);
            }
          } else {
            print('⚪ Không có token hoặc token không hợp lệ, vào LoginScreen');
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
