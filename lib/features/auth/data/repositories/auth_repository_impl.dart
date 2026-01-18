import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Box<UserModel> _userBox;
  final Box _usersDbBox;

  AuthRepositoryImpl(this._googleSignIn, this._userBox, this._usersDbBox);

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account != null) {
        final user = UserModel(
          id: account.id,
          email: account.email,
          displayName: account.displayName ?? 'User',
          photoUrl: account.photoUrl,
        );
        // Save to Hive
        await _userBox.put('currentUser', user);
        return user;
      }
    } catch (e) {
      // Handle error or return null
      // debugPrint('Google Sign In Error: $e');
    }
    return null;
  }

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // Direct Hive Check (Local-First/Local-Only)
      final userData = _usersDbBox.get(email);
      if (userData != null) {
        final localUser = UserModel.fromJson(
          Map<String, dynamic>.from(userData),
        );
        if (localUser.password == password) {
          // Success: Login via Hive
          await _userBox.put('currentUser', localUser);
          return localUser;
        } else {
          throw Exception('Invalid credentials');
        }
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      // Check if user already exists
      if (_usersDbBox.containsKey(email)) {
        throw Exception('User already exists');
      }

      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        email: email,
        displayName: name,
        password: password,
        photoUrl: '', // Default empty or a placeholder
      );

      // Save to DB Hive
      await _usersDbBox.put(email, newUser.toJson());

      // Log them in locally
      await _userBox.put('currentUser', newUser);

      return newUser;
    } catch (e) {
      throw Exception('Signup error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _userBox.delete('currentUser');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _userBox.get('currentUser');
  }

  @override
  Future<bool> get isSignedIn async {
    return _userBox.containsKey('currentUser');
  }

  @override
  Future<void> updateProfilePhoto(String path) async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(photoUrl: path);

      // Update session box
      await _userBox.put('currentUser', updatedUser);

      // Update db box if exists
      if (_usersDbBox.containsKey(currentUser.email)) {
        final userData = _usersDbBox.get(currentUser.email);
        final updatedUserData = Map<String, dynamic>.from(userData);
        updatedUserData['userImageUrl'] = path;
        await _usersDbBox.put(currentUser.email, updatedUserData);
      }
    }
  }

  @override
  Future<void> updateEmail(String newEmail) async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      final oldEmail = currentUser.email;
      final updatedUser = currentUser.copyWith(email: newEmail);

      // Update session box
      await _userBox.put('currentUser', updatedUser);

      // Update db box: remove old email entry and add new one
      if (_usersDbBox.containsKey(oldEmail)) {
        final userData = _usersDbBox.get(oldEmail);
        await _usersDbBox.delete(oldEmail);
        await _usersDbBox.put(newEmail, userData);
      }
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(password: newPassword);

      // Update session box
      await _userBox.put('currentUser', updatedUser);

      // Update db box if exists
      if (_usersDbBox.containsKey(currentUser.email)) {
        final userData = _usersDbBox.get(currentUser.email);
        final updatedUserData = Map<String, dynamic>.from(userData);
        updatedUserData['password'] = newPassword;
        await _usersDbBox.put(currentUser.email, updatedUserData);
      }
    }
  }

  @override
  Future<void> updateDisplayName(String newName) async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(displayName: newName);

      // Update session box
      await _userBox.put('currentUser', updatedUser);

      // Update db box if exists
      if (_usersDbBox.containsKey(currentUser.email)) {
        final userData = _usersDbBox.get(currentUser.email);
        final updatedUserData = Map<String, dynamic>.from(userData);
        updatedUserData['fullName'] = newName;
        await _usersDbBox.put(currentUser.email, updatedUserData);
      }
    }
  }

  @override
  Future<void> deleteAccount() async {
    final currentUser = _userBox.get('currentUser');
    if (currentUser != null) {
      // Remove from DB
      await _usersDbBox.delete(currentUser.email);
    }
    // Sign out (clears session box and google sign in)
    await signOut();
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final List<UserModel> users = [];
      // Iterate through values in the users_db box
      // Since it's a dynamic box, values might be Maps
      for (var value in _usersDbBox.values) {
        if (value is Map) {
          try {
            final userMap = Map<String, dynamic>.from(value);
            users.add(UserModel.fromJson(userMap));
          } catch (e) {
            // Skip invalid entries
          }
        }
      }
      return users;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> deleteUser(String email) async {
    // Delete from DB
    if (_usersDbBox.containsKey(email)) {
      await _usersDbBox.delete(email);
    }
  }
}
