import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/responsive_page.dart';
import 'forgot_password_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withOpacity(0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: ResponsivePage(
            child: DefaultTabController(
              length: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    const SizedBox(height: 80),
                    const SizedBox(height: 32),
                    Text(
                      'Chào mừng trở lại!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
                    const SizedBox(height: 18),

                    // TabBar
                    Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(
                          0.3,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        labelColor: theme.colorScheme.primary,
                        unselectedLabelColor:
                            theme.colorScheme.onSurfaceVariant,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: 'Email'),
                          Tab(text: 'OTP'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 24),

                    // Forms
                    const SizedBox(
                      height: 400,
                      child: TabBarView(
                        children: [_EmailLoginForm(), _PhoneLoginForm()],
                      ),
                    ).animate().fadeIn(delay: 500.ms),

                    const _SocialDivider(),
                    const SizedBox(height: 24),

                    // Google Login
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      onPressed: auth.isLoading
                          ? null
                          : () => auth.signInWithGoogle(),
                      icon: Image.network(
                        'https://tse4.mm.bing.net/th/id/OIP.OaODcbALVA7X16ORk2TykwHaHa?w=512&h=512&rs=1&pid=ImgDetMain&o=7&rm=3',
                        height: 20,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.login_rounded, size: 20),
                      ),
                      label: const Text('Tiếp tục với Google'),
                    ).animate().fadeIn(delay: 600.ms),

                    const SizedBox(height: 24),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'Chưa có tài khoản?',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text('Đăng ký ngay'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.outlineVariant;
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Hoặc',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

class _EmailLoginForm extends ConsumerStatefulWidget {
  const _EmailLoginForm();

  @override
  ConsumerState<_EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends ConsumerState<_EmailLoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'Địa chỉ Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(
              hintText: 'Mật khẩu',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: Validators.password,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text('Quên mật khẩu?'),
            ),
          ),
          if (auth.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                auth.errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Đăng nhập',
            icon: Icons.arrow_forward,
            isLoading: auth.isLoading,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                auth.signInWithEmail(_email.text, _password.text);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _PhoneLoginForm extends ConsumerStatefulWidget {
  const _PhoneLoginForm();

  @override
  ConsumerState<_PhoneLoginForm> createState() => _PhoneLoginFormState();
}

class _PhoneLoginFormState extends ConsumerState<_PhoneLoginForm> {
  final _phone = TextEditingController(text: '+84');
  final _otp = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final isOtpSent = auth.verificationId != null;

    return Column(
      children: [
        TextFormField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Số điện thoại (VD: +84...)',
            prefixIcon: const Icon(Icons.phone_outlined),
            suffixIcon: IconButton(
              onPressed: auth.isLoading
                  ? null
                  : () => auth.sendOtp(_phone.text),
              icon: Icon(isOtpSent ? Icons.refresh : Icons.send_rounded),
              tooltip: isOtpSent ? 'Gửi lại OTP' : 'Gửi OTP',
            ),
          ),
        ),
        const SizedBox(height: 16),
        AnimatedOpacity(
          opacity: isOtpSent ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 300),
          child: TextFormField(
            controller: _otp,
            enabled: isOtpSent,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Mã OTP 6 số',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
          ),
        ),
        if (auth.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            auth.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 13,
            ),
          ),
        ],
        const SizedBox(height: 24),
        AppButton(
          label: 'Xác minh OTP',
          icon: Icons.verified_user_outlined,
          isLoading: auth.isLoading,
          onPressed: !isOtpSent || auth.isLoading
              ? null
              : () => auth.verifyOtp(_otp.text),
        ),
      ],
    );
  }
}
