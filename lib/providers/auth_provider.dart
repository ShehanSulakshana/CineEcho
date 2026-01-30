import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  bool _isLoading = false;

  AuthenticationProvider() {
    _currentUser = _firebaseAuth.currentUser;
    _firebaseAuth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserProfile({
    required String uid,
    required String email,
    required String displayName,
    String? about,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'displayName': displayName,
        'email': email,
        if (about != null) 'about': about,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firebaseAuth.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserName({required String username}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _currentUser?.updateDisplayName(username);
      await _currentUser?.reload();
      _currentUser = _firebaseAuth.currentUser;
      final uid = _currentUser?.uid;
      final email = _currentUser?.email;
      if (uid != null && email != null) {
        await saveUserProfile(uid: uid, email: email, displayName: username);
      }
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final result = await _firebaseAuth.signInWithCredential(credential);
      final user = result.user;
      if (user != null) {
        await saveUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
        );
      }
      return result;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOutGoogle() async {
    try {
      await _googleSignIn.signOut();
      await signOut();
    } catch (e) {
      debugPrint('Error signing out from Google: $e');
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      if (_currentUser != null && !_currentUser!.emailVerified) {
        await _currentUser!.sendEmailVerification();
      }
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      rethrow;
    }
  }

  Future<void> reloadUser() async {
    try {
      await _currentUser?.reload();
      _currentUser = _firebaseAuth.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }
}
