import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;

  UserProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await DatabaseHelper.instance.getFirstUser();
      
      // Sync dengan Firebase jika sedang login
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && _user != null) {
        bool needUpdate = false;
        String newName = _user!.name;
        String? newPhoto = _user!.photoPath;
        
        if (firebaseUser.displayName != null && firebaseUser.displayName!.isNotEmpty && firebaseUser.displayName != _user!.name) {
          newName = firebaseUser.displayName!;
          needUpdate = true;
        }
        if (firebaseUser.photoURL != null && firebaseUser.photoURL != _user!.photoPath) {
          newPhoto = firebaseUser.photoURL;
          needUpdate = true;
        }
        
        if (needUpdate) {
          _user = _user!.copyWith(name: newName, photoPath: newPhoto);
          await DatabaseHelper.instance.updateUser(_user!);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error loading user: $e');
    }
  }
  Future<void> createUser(UserModel user) async {
    try {
      await DatabaseHelper.instance.createUser(user);
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error creating user: $e');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await DatabaseHelper.instance.updateUser(user);
      _user = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
  }

  Future<void> toggleBalanceHidden() async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(
        balanceHidden: !_user!.balanceHidden,
      );
      await updateUser(updatedUser);
    }
  }

  Future<void> toggleBiometric(bool enabled) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(
        biometricEnabled: enabled,
      );
      await updateUser(updatedUser);
    }
  }

  Future<void> updatePin(String pin) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(pin: pin);
      await updateUser(updatedUser);
    }
  }

  Future<void> updatePhoto(String photoPath) async {
    if (_user != null) {
      final updatedUser = _user!.copyWith(photoPath: photoPath);
      await updateUser(updatedUser);
    }
  }

  Future<void> logout() async {
    _user = null;
    // Keep PIN set, only clear user data
    notifyListeners();
  }

  // Shared Preferences helpers
  Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyOnboarded) ?? false;
  }

  Future<void> setOnboarded(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyOnboarded, value);
  }

  Future<bool> isPinSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyPinSet) ?? false;
  }

  Future<void> setPinSet(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyPinSet, value);
  }

  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, value);
  }
}
