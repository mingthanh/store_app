import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:store_app/services/firestore_service.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Keep Firebase Auth profile consistent with our Firestore profile
    try {
      await cred.user!.updateDisplayName(name);
      // No need to reload for most cases, but safe to do so to immediately reflect changes
      await cred.user!.reload();
    } catch (_) {
      // Ignore non-critical profile update errors to avoid blocking sign-up
    }
    final uid = cred.user!.uid;

    final isAdmin = name.toLowerCase() == 'admin' || email.toLowerCase().startsWith('admin0411@');
    await FirestoreService.instance.upsertUserProfile(
      userId: uid,
      name: name,
      email: email,
      extra: {
        'role': isAdmin ? 'admin' : 'user',
        'createdAt': FieldValue.serverTimestamp(),
      },
    );
    return cred;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);

    // Ensure user doc exists and role assignment for special admin email
    final uid = cred.user!.uid;
    final isAdmin = email.toLowerCase().startsWith('admin0411@');
    await FirestoreService.instance.upsertUserProfile(
      userId: uid,
      name: cred.user!.displayName ?? '',
      email: email,
      extra: {
        if (isAdmin) 'role': 'admin',
      },
    );
    return cred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
