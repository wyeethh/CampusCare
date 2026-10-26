import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ---------------------------------------------------------------------------
// Handles Firebase Authentication + Firestore profile of the student
// ---------------------------------------------------------------------------
class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  String get uid => _auth.currentUser!.uid;

  // 1. Register using email and password
  Future<void> register({
    required String fullName,
    required String studentId,
    required String email,
    required String password,
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    User user = cred.user!;
    await user.updateDisplayName(fullName.trim());

    // Save the student profile: users/{uid}
    await _db.collection('users').doc(user.uid).set({
      'fullName': fullName.trim(),
      'studentId': studentId.trim(),
      'email': email.trim(),
      'program': '',
      'contactNumber': '',
      'emergencyContact': '',
      'photoUrl': '',
      'bloodType': '',
      'allergies': '',
      'conditions': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Login
  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // 3. Forgot password
  Future<void> resetPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  // 4. Logout
  Future<void> signOut() => _auth.signOut();

  // Student profile document
  Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream(String userId) =>
      _db.collection('users').doc(userId).snapshots();

  Future<void> saveProfile(String userId, Map<String, dynamic> data) =>
      _db.collection('users').doc(userId).set(data, SetOptions(merge: true));

  // Appointments of the student
  Stream<QuerySnapshot<Map<String, dynamic>>> appointmentsStream(String userId) =>
      _db
          .collection('users')
          .doc(userId)
          .collection('appointments')
          .orderBy('date', descending: true)
          .snapshots();

  CollectionReference<Map<String, dynamic>> appointmentsRef(String userId) =>
      _db.collection('users').doc(userId).collection('appointments');

  // Friendly error messages
  static String message(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'That email is already registered.';
        case 'invalid-email':
          return 'Please enter a valid email.';
        case 'weak-password':
          return 'Password must be at least 8 characters.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password.';
        case 'too-many-requests':
          return 'Too many attempts. Try again later.';
        case 'network-request-failed':
          return 'No internet connection.';
        default:
          return e.message ?? 'Authentication error.';
      }
    }
    return 'Something went wrong. Please try again.';
  }
}
