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

  AuthProvider() {
    _auth.authStateChanges().listen((firebaseUser) async {
      user = firebaseUser;
      if (user != null) {
        await _ensureUserDoc(user!);
      }
      loading = false;
      notifyListeners();
    });
  }

  bool get isAuthenticated => user != null;
  bool get isAdmin => user?.email != null && adminEmails.contains(user!.email);

  Future<void> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    loading = true;
    notifyListeners();
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await credential.user?.updateDisplayName(displayName);
    await _ensureUserDoc(credential.user!);
    loading = false;
    notifyListeners();
  }

  Future<void> signInWithEmail(String email, String password) async {
    loading = true;
    notifyListeners();
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    loading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.signOut();
    user = null;
    notifyListeners();
  }

  Future<void> updateDisplayName(String displayName) async {
    if (user == null) return;
    await user!.updateDisplayName(displayName);
    await _ensureUserDoc(user!);
    user = _auth.currentUser;
    notifyListeners();
  }

  Future<void> _ensureUserDoc(User user) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'uid': user.uid,
        'email': user.email,
        'displayName':
            user.displayName ?? user.email?.split('@').first ?? 'Người dùng',
        'credits': 0,
        'totalPurchased': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
