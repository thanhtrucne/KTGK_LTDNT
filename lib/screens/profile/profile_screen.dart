import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/user_profile.dart';
import '../../providers/providers.dart';
import '../../utils/validators.dart';
import '../../widgets/error_state.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authProvider);
    final themeProv = ref.watch(themeProvider);
    final profileService = ref.watch(profileServiceProvider);
    final user = auth.currentUser;
    
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        actions: [
          // Nút chuyển đổi Theme
          IconButton(
            onPressed: () => themeProv.toggleTheme(!themeProv.isDark),
            icon: Icon(themeProv.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          ),
          IconButton(
            tooltip: 'Đăng xuất',
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<UserProfile?>(
        stream: profileService.watchProfile(user.uid),
        builder: (context, snapshot) {
          // Xử lý khi đang tải hoặc có lỗi (thường là lỗi quyền khi profile chưa tồn tại)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Nếu có lỗi (ví dụ: permission-denied), chúng ta sẽ tạo một profile tạm thời từ thông tin Auth
          final profile = snapshot.data ?? UserProfile(
            uid: user.uid,
            name: user.displayName ?? 'Người dùng mới',
            email: user.email ?? '',
            phone: user.phoneNumber ?? '',
            updatedAt: DateTime.now(),
          );
          
          return _ProfileForm(profile: profile, firebaseUser: user);
        },
      ),
    );
  }
}

class _ProfileForm extends ConsumerStatefulWidget {
  const _ProfileForm({required this.profile, required this.firebaseUser});

  final UserProfile profile;
  final User firebaseUser;

  @override
  ConsumerState<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  String? _photoBase64;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.name);
    _email = TextEditingController(
      text: widget.profile.email.isNotEmpty ? widget.profile.email : widget.firebaseUser.email ?? '',
    );
    _phone = TextEditingController(
      text: widget.profile.phone.isNotEmpty ? widget.profile.phone : widget.firebaseUser.phoneNumber ?? '',
    );
    _photoBase64 = widget.profile.photoBase64;
  }

  @override
  void didUpdateWidget(covariant _ProfileForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.updatedAt != widget.profile.updatedAt) {
      setState(() => _photoBase64 = widget.profile.photoBase64);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ảnh đại diện với hiệu ứng
            Stack(
              children: [
                _buildAvatar(),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: FloatingActionButton.small(
                    onPressed: _pickImage,
                    child: const Icon(Icons.camera_alt_rounded),
                  ),
                ),
              ],
            ).animate().scale(delay: 200.ms),
            
            const SizedBox(height: 32),
            
            // Trường nhập liệu
            _buildField(
              controller: _name,
              label: 'Họ và tên',
              icon: Icons.person_outline_rounded,
              delay: 300,
              validator: (v) => Validators.required(v, 'Họ và tên'),
            ),
            _buildField(
              controller: _email,
              label: 'Email',
              icon: Icons.email_outlined,
              delay: 400,
              enabled: widget.profile.email.isEmpty,
              validator: widget.profile.email.isEmpty ? Validators.email : null,
            ),
            _buildField(
              controller: _phone,
              label: 'Số điện thoại',
              icon: Icons.phone_outlined,
              delay: 500,
              validator: Validators.phone,
            ),
            
            const SizedBox(height: 32),
            
            // Nút Lưu thay đổi
            FilledButton.icon(
              onPressed: _saving ? null : _saveProfile,
              icon: _saving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.save_rounded),
              label: Text(_saving ? 'Đang lưu...' : 'Lưu thay đổi'),
            ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (_photoBase64 != null) {
      final bytes = base64Decode(_photoBase64!);
      return CircleAvatar(
        radius: 60,
        backgroundImage: MemoryImage(bytes),
      );
    }
    return CircleAvatar(
      radius: 60,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(Icons.person_rounded, size: 60, color: Theme.of(context).colorScheme.primary),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required int delay,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
        ),
      ).animate().fadeIn(delay: delay.ms).moveY(begin: 10, end: 0),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 75);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() => _photoBase64 = base64Encode(bytes));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _saving = true);
    try {
      final profile = UserProfile(
        uid: widget.profile.uid,
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        photoBase64: _photoBase64,
        updatedAt: DateTime.now(),
        role: widget.profile.role,
      );
      
      await ref.read(profileServiceProvider).updateProfile(profile);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công!'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

}
