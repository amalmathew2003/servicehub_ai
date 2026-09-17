import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthDatasource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthDatasource({
    required this.auth,
    required this.firestore,
  });

  // ============================
  // EMAIL REGISTER
  // ============================

  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
  }) async {
    return await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ============================
  // EMAIL LOGIN
  // ============================

  Future<UserCredential> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ============================
  // GOOGLE LOGIN
  // ============================

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn.instance;

    // Initialize Google Sign-In.
    await googleSignIn.initialize();

    // Start Google authentication.
    final GoogleSignInAccount googleUser =
        await googleSignIn.authenticate();

    // Get authentication information.
    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    // Create Firebase credential.
    final AuthCredential credential =
        GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Login to Firebase.
    return await auth.signInWithCredential(credential);
  }

  // ============================
  // LOGOUT
  // ============================

  Future<void> logout() async {
    await auth.signOut();

    await GoogleSignIn.instance.signOut();
  }

  // ============================
  // CREATE FIRESTORE USER
  // ============================

  Future<void> createUserDocument({
    required User user,
    required String name,
    required String role,
  }) async {
    await firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email ?? '',
      'phone': user.phoneNumber,
      'role': role,
      'profileImage': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================
  // GET USER
  // ============================

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDocument(
    String uid,
  ) async {
    return await firestore
        .collection('users')
        .doc(uid)
        .get();
  }
}