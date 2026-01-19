import 'package:firebase_auth/firebase_auth.dart';
//import 'package:provider/provider.dart';

// Provider<AuthServices> authServices = Provider(
//   create: (context) => AuthServices(),
// );

class AuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }



  Future<void> updateUserName({required String username}) async {
    await currentUser!.updateDisplayName(username);
  }
}
