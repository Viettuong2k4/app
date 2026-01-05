import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../core/constants/enums.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();

  UserModel? _userModel;
  User? _firebaseUser;
  bool _isLoading = false;

  UserModel? get user => _userModel;
  Map<String, dynamic> get userInfo {
    if (_userModel == null) return {};
    return {
      'name': _userModel!.name,
      'fullName': _userModel!.name,
      'email': _userModel!.email,
      'phone': _userModel!.phone,
      'address': _userModel!.address,
      'gender': _userModel!.gender.name,
      'dob': _userModel!.dob,
      'height': _userModel!.height,
      'weight': _userModel!.weight,
    };
  }

  String get userName => _userModel?.name ?? "Người dùng";
  String get userEmail => _userModel?.email ?? "";
  String get userAge => _userModel?.age.toString() ?? "--";

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    _firebaseUser = _authRepository.currentUser;
    if (_firebaseUser != null) {
      fetchUserInfo(_firebaseUser!.uid);
    }
  }

  Future<void> fetchUserInfo(String uid) async {
    try {
      _userModel = await _authRepository.getUserData(uid);
      notifyListeners();
    } catch (e) {
      print("Lỗi fetch user: $e");
    }
  }

  Future<bool> tryAutoLogin() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      await fetchUserInfo(user.uid);
      return true;
    }
    return false;
  }

  Future<void> login(
    String email,
    String password,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.signIn(email, password);
      _firebaseUser = _authRepository.currentUser;
      if (_firebaseUser != null) {
        await fetchUserInfo(_firebaseUser!.uid);
      }
      onSuccess();
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? "Lỗi đăng nhập");
    } catch (e) {
      onError("Đã xảy ra lỗi: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String name,
    String email,
    String password,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.signUp(email, password, name);
      _firebaseUser = _authRepository.currentUser;
      if (_firebaseUser != null) {
        _userModel = UserModel(
          id: _firebaseUser!.uid,
          name: name,
          email: email,
        );
      }
      onSuccess();
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? "Lỗi đăng ký");
    } catch (e) {
      onError("Đã xảy ra lỗi: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset Password
  Future<void> resetPassword(
    String email,
    VoidCallback onSuccess,
    Function(String) onError,
  ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.sendPasswordResetEmail(email);
      onSuccess();
    } on FirebaseAuthException catch (e) {
      onError(e.message ?? "Lỗi gửi email");
    } catch (e) {
      onError("Lỗi: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile({
    required int age,
    required String gender,
    required double height,
    required double weight,
    String? conditions,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (_userModel == null) {
      onError("Không tìm thấy người dùng");
      return;
    }
    _isLoading = true;
    notifyListeners();

    try {
      final genderEnum = Gender.values.firstWhere(
        (e) => e.name == gender,
        orElse: () => Gender.other,
      );

      final updatedUser = UserModel(
        id: _userModel!.id,
        name: _userModel!.name,
        email: _userModel!.email,
        gender: genderEnum,
        height: height,
        weight: weight,
        dob: _userModel!.dob,
      );

      await _authRepository.updateUserData(updatedUser);
      _userModel = updatedUser;
      onSuccess();
    } catch (e) {
      onError("Lỗi cập nhật: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserInfo(Map<String, dynamic> data) async {
    if (_userModel == null) return;

    final newUser = UserModel(
      id: _userModel!.id,
      name: data['fullName'] ?? _userModel!.name,
      email: _userModel!.email,
      phone: data['phone'] ?? _userModel!.phone,
      address: data['address'] ?? _userModel!.address,
      gender: Gender.values.firstWhere(
        (e) => e.name == data['gender'],
        orElse: () => _userModel!.gender,
      ),
      dob: data['dob'] ?? _userModel!.dob,
      height: data['height'] ?? _userModel!.height,
      weight: data['weight'] ?? _userModel!.weight,
    );

    await _authRepository.updateUserData(newUser);
    _userModel = newUser;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.signOut();
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }
}
