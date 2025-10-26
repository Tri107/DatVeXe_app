import 'dart:async';
import 'package:datvexe_app/screens/common/splash_screen.dart';
import 'package:datvexe_app/screens/khachhang/home_screen.dart';
import 'package:datvexe_app/screens/khachhang/payment_successful.dart';
import 'package:datvexe_app/screens/taixe/taixe_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:datvexe_app/config/api.dart';
import 'package:datvexe_app/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:datvexe_app/models/TaiKhoan.dart';
import 'package:app_links/app_links.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Api.loadToken();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Thêm GlobalKey để điều hướng global
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSub;
  TaiKhoan? _user;
  bool _isLoading = true;
  Uri? _initialDeepLink;

  @override
  void initState() {
    super.initState();
    _initApp();
    _initDeepLinks();
  }

  // Load user từ token
  Future<void> _initApp() async {
    _user = await _getUserFromToken();
    setState(() => _isLoading = false);
  }

  //Giải mã token trong SharedPreferences
  Future<TaiKhoan?> _getUserFromToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    debugPrint(' Token SharedPreferences: $token');

    if (token != null && token.isNotEmpty) {
      await Api.setToken(token);
      try {
        final decoded = JwtDecoder.decode(token);
        debugPrint(' Payload token: $decoded');
        return TaiKhoan(
          sdt: decoded['sdt'] ?? '',
          role: decoded['role'] ?? 'user',
        );
      } catch (e) {
        debugPrint('️ Lỗi giải mã token: $e');
      }
    }
    return null;
  }

  // Bắt deep link VNPay redirect
  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Khi app đang mở (foreground)
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (uri == null) return;
      debugPrint('🔗 Nhận deep link realtime: $uri');
      _handleDeepLink(uri);
    });

    // Khi app mở từ deep link (launch)
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      debugPrint(' Deep link khi mở app: $uri');
      setState(() {
        _initialDeepLink = uri;
      });
    }
  }

  // Xử lý deep link với navigatorKey
  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'datvexe' && uri.host == 'payment-success') {
      debugPrint(' Điều hướng đến PaymentSuccessful');

      // Đảm bảo Navigator đã sẵn sàng
      Future.delayed(const Duration(milliseconds: 200), () {
        _navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const PaymentSuccessful()),
          (_) => false,
        );
      });
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Đặt vé xe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          // Dùng gradient gián tiếp qua flexibleSpace (xem dưới)
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 22,
          ),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        //  Font chữ tổng thể
        fontFamily: 'Roboto',

        // ⚙ Màu nền tổng thể
        scaffoldBackgroundColor: Colors.grey[100],
      ),

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi', 'VN')],
      locale: const Locale('vi', 'VN'),
      home: Builder(
        builder: (context) {
          // Nếu deep link tồn tại → vào PaymentSuccessful luôn
          if (_initialDeepLink != null &&
              _initialDeepLink!.scheme == 'datvexe' &&
              _initialDeepLink!.host == 'payment-success') {
            return const PaymentSuccessful();
          }

          // Bình thường → hiển thị app như cũ
          if (_isLoading) return const SplashScreen();

          if (_user != null) {
            return _user!.role == 'taixe'
                ? TaiXeHomeScreen(user: _user!)
                : HomeScreen(user: _user!);
          }

          return const LoginScreen();
        },
      ),
    );
  }
}
