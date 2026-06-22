import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

const adminEmails = [
  'adminlabantuyensinh@gmail.com',
  'hoanglong27404@gmail.com',
];

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? user;
  bool loading = true;
  String? initializationError;

  AuthProvider() {
    _initialize();
  }

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.email != null && adminEmails.contains(user!.email);

  Future<void> _initialize() async {
    try {
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
        final redirectCredential = await _auth.getRedirectResult();
        user = redirectCredential.user ?? _auth.currentUser;
      } else {
        user = _auth.currentUser;
      }

      if (user != null) {
        await _trySyncUserDoc(user!);
      }
    } catch (error, stackTrace) {
      initializationError = error.toString();
      debugPrint('Unable to restore the authentication session: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      loading = false;
      notifyListeners();
    }

    _auth.authStateChanges().listen((firebaseUser) async {
      user = firebaseUser;
      if (user != null) {
        await _trySyncUserDoc(user!);
      }
      notifyListeners();
    });
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    await _runLoading(() async {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final createdUser = credential.user;
      if (createdUser == null) {
        throw StateError('Firebase did not return the newly created user.');
      }
      await createdUser.updateDisplayName(displayName);
      await _trySyncUserDoc(createdUser);
    });
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _runLoading(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<void> signInWithGoogle() async {
    await _runLoading(() async {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

      if (kIsWeb) {
        await _auth.signInWithPopup(provider);
      } else {
        await _auth.signInWithProvider(provider);
      }
    });
  }

  Future<T> _runLoading<T>(Future<T> Function() action) async {
    loading = true;
    notifyListeners();
    try {
      return await action();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    notifyListeners();
  }

  Future<void> updateDisplayName(String displayName) async {
    if (user == null) return;
    await user!.updateDisplayName(displayName);
    await _syncUserDoc(user!);
    user = _auth.currentUser;
    notifyListeners();
  }

  Future<void> _syncUserDoc(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'displayName':
          user.displayName ?? user.email?.split('@').first ?? 'Người dùng',
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _trySyncUserDoc(User user) async {
    try {
      await _syncUserDoc(user);
    } catch (error, stackTrace) {
      debugPrint('Unable to sync the user profile: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
