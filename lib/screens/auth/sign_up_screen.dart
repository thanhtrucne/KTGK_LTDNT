import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/responsive_page.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký tài khoản'),
      ),
      body: ResponsivePage(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(
                  Icons.person_add_outlined,
                  size: 80,
                  color: theme.colorScheme.primary,
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 40),
                
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: Validators.email,
                ).animate().fadeIn(delay: 100.ms).moveY(begin: 10, end: 0),
                
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: Validators.password,
                ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0),
                
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Xác nhận mật khẩu',
                    prefixIcon: Icon(Icons.check_circle_outline),
                  ),
                  validator: (v) {
                    if (v != _password.text) return 'Mật khẩu không khớp';
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).moveY(begin: 10, end: 0),
                
                const SizedBox(height: 40),
                
                if (auth.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      auth.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                
                AppButton(
                  label: 'Đăng ký ngay',
                  icon: Icons.check_rounded,
                  isLoading: auth.isLoading,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await auth.signUpWithEmail(
                        _email.text,
                        _password.text,
                      );
                      // Nếu đăng ký thành công (không có lỗi), AuthGate sẽ tự chuyển về HomeScreen
                      // Chúng ta chỉ cần pop màn hình SignUp này đi là xong.
                      if (mounted && auth.errorMessage == null && auth.isLoggedIn) {
                        Navigator.of(context).pop();
                      }
                    }
                  },
                ).animate().fadeIn(delay: 600.ms),
                
                const SizedBox(height: 24),
                
                // Footer sử dụng Wrap để tránh lỗi tràn màn hình
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Đã có tài khoản?'),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Đăng nhập'),
                    ),
                  ],
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
