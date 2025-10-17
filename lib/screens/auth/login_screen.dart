import 'package:flutter/material.dart';
import '../../models/TaiKhoan.dart';
import '../../services/Auth_Services.dart';
import '../khachhang/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sdtCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;
  String? _error;
  TaiKhoan? _user;

  @override
  void dispose() {
    _sdtCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user =
      await AuthService.login(_sdtCtrl.text.trim(), _passCtrl.text.trim());
      if (user == null) {
        setState(() => _error = 'Sai SĐT hoặc mật khẩu');
        return;
      }
      if (!mounted) return;
      setState(() => _user = user);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thành công: ${user.sdt} (${user.role})')),
      );

      // ✅ Điều hướng demo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  TextFormField(
                    controller: _sdtCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'Số điện thoại'),
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Vui lòng nhập SĐT' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Mật khẩu'),
                    validator: (v) =>
                    (v == null || v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
                  ),
                  const SizedBox(height: 16),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _onLogin,
                    child: _loading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Text('Đăng nhập'),
                  ),
                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _goToRegister,
                    child: const Text(
                      'Chưa có tài khoản? Tạo tài khoản mới',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                  if (_user != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: ListTile(
                        title: Text('Xin chào ${_user!.sdt}'),
                        subtitle: Text('Role: ${_user!.role}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
