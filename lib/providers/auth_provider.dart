import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class AppAuthProvider extends ChangeNotifier {
  AppAuthProvider(this._authService, this._profileService) {
    currentUser = _authService.currentUser;
    _authService.authStateChanges.listen((user) async {
      currentUser = user;
      if (user != null) {
        // Chỉ lắng nghe hồ sơ, không tự ý tạo mới ở đây để tránh ghi đè dữ liệu rỗng
        _profileService.watchProfile(user.uid).listen((profile) {
          currentProfile = profile;
          notifyListeners();
        });
      } else {
        currentProfile = null;
      }
      notifyListeners();
    });
  }

  final AuthService _authService;
  final ProfileService _profileService;

  User? currentUser;
  UserProfile? currentProfile;
  bool isLoading = false;
  String? errorMessage;
  String? verificationId;

  bool get isLoggedIn => currentUser != null;

  Future<void> signInWithEmail(String email, String password) async {
    await _guard(() async {
      final credential = await _authService.signInWithEmail(email, password);
      if (credential.user != null) {
        await _profileService.ensureProfile(credential.user!);
      }
    });
  }

  Future<void> signUpWithEmail(
    String email,
    String password, {
    String? name,
    String? phone,
  }) async {
    await _guard(() async {
      final credential = await _authService.signUpWithEmail(email, password);
      final user = credential.user;
      if (user != null) {
        await _profileService.ensureProfile(user, name: name, phone: phone);
      }
    });
  }

  Future<void> signInWithGoogle() async {
    await _guard(() async {
      final credential = await _authService.signInWithGoogle();
      final user = credential.user;
      if (user != null) {
        await _profileService.ensureProfile(user);
      }
    });
  }

  Future<void> sendPasswordReset(String email) async {
    await _guard(() async {
      await _authService.sendPasswordReset(email);
    });
  }

  Future<void> sendOtp(String phoneNumber) async {
    await _guard(() {
      return _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
          if (userCred.user != null) {
            await _profileService.ensureProfile(userCred.user!);
          }
        },
        verificationFailed: (error) {
          errorMessage = _friendlyError(error);
          notifyListeners();
        },
        codeSent: (id, _) {
          verificationId = id;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (id) {
          verificationId = id;
        },
      );
    });
  }

  Future<void> verifyOtp(String smsCode) async {
    final id = verificationId;
    if (id == null) {
      errorMessage = 'Vui lòng gửi OTP trước.';
      notifyListeners();
      return;
    }
    await _guard(() async {
      final userCred = await _authService.signInWithSmsCode(
        verificationId: id,
        smsCode: smsCode,
      );
      if (userCred.user != null) {
        await _profileService.ensureProfile(userCred.user!);
      }
    });
  }

  Future<void> signOut() => _authService.signOut();

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> _guard(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (error) {
      errorMessage = _friendlyError(error);
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _friendlyError(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-email' => 'Email không hợp lệ.',
      'user-not-found' => 'Không tìm thấy tài khoản.',
      'wrong-password' || 'invalid-credential' => 'Thông tin đăng nhập sai.',
      'email-already-in-use' => 'Email đã được sử dụng.',
      'weak-password' => 'Mật khẩu quá yếu.',
      'google-cancelled' => 'Bạn đã hủy đăng nhập Google.',
      'invalid-verification-code' => 'Mã OTP không đúng.',
      _ => error.message ?? 'Đã có lỗi xảy ra.',
    };
  }
}
