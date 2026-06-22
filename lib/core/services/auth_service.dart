import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static final _localAuth = LocalAuthentication();
  
  static const String _pinKey = 'user_hashed_pin';
  static const String _uidKey = 'user_uid';
  static const String _appLockKey = 'app_lock_enabled';

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: const <String>['email']);
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── Google Sign-In ─────────────────────────────────────────────────────────

  static Future<UserCredential?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
        }, SetOptions(merge: true));
        
        await _storage.write(key: _uidKey, value: user.uid);
      }
      return userCredential;
    } catch (e) {
      // ignore: avoid_print
      print('Google sign in error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await _storage.delete(key: _uidKey);
  }

  // ── Biometrics ─────────────────────────────────────────────────────────────

  /// Checks if biometrics are available on the device
  static Future<bool> canUseBiometrics() async {
    final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
    final canAuthenticate =
        canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();
    return canAuthenticate;
  }

  /// Attempts to authenticate the user with biometrics
  static Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock Trezo',
      );
    } catch (e) {
      return false;
    }
  }

  // ── PIN Management ─────────────────────────────────────────────────────────

  static String _hashPin(String pin) {
    var bytes = utf8.encode(pin); // data being hashed
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<void> setPin(String pin) async {
    final hashed = _hashPin(pin);
    await _storage.write(key: _pinKey, value: hashed);
  }

  static Future<bool> verifyPin(String pin) async {
    final storedHash = await _storage.read(key: _pinKey);
    if (storedHash == null) return false;
    final currentHash = _hashPin(pin);
    return storedHash == currentHash;
  }

  static Future<bool> isPinSet() async {
    final storedHash = await _storage.read(key: _pinKey);
    return storedHash != null && storedHash.isNotEmpty;
  }

  // ── App Lock Toggle ────────────────────────────────────────────────────────

  static Future<bool> isAppLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_appLockKey) ?? false;
  }

  static Future<void> setAppLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_appLockKey, enabled);
  }

  // ── UID Management ─────────────────────────────────────────────────────────

  /// Generates (if not exists) and returns the user UID
  static Future<String> getOrCreateUid() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) return user.uid;

    String? uid = await _storage.read(key: _uidKey);
    if (uid == null || uid.isEmpty) {
      // Create a simple UUID-like string since we might not have uuid package
      // In a real app with Firebase, this would be the Firebase UID.
      uid = '${DateTime.now().millisecondsSinceEpoch}_${_hashPin(DateTime.now().toString()).substring(0, 16)}';
      await _storage.write(key: _uidKey, value: uid);
    }
    return uid;
  }

  static Future<String?> getUid() async {
    return await _storage.read(key: _uidKey);
  }
}
