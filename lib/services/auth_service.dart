// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Create user doc helper
  Future<void> _createUserDoc(User user, {required bool isTrainer}) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = {
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'photoURL': user.photoURL,
      'isTrainer': isTrainer,
      'createdAt': FieldValue.serverTimestamp(),
      'trainerId': null,
      'trainerCode': isTrainer ? _generateTrainerCode() : null,
    };
    await userRef.set(doc, SetOptions(merge: true));
  }

  String _generateTrainerCode() {
    // short unique code — adapt as needed (collision-check further if scale)
    final id = Uuid().v4().substring(0, 8);
    // optionally convert to uppercase, remove dashes
    return id.replaceAll('-', '').substring(0, 6).toUpperCase();
  }

  // Email signup
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String displayName,
    required Future<bool> Function() askIsTrainerIfNeeded,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await cred.user!.updateDisplayName(displayName);
    final isTrainer = await askIsTrainerIfNeeded();
    await _createUserDoc(cred.user!, isTrainer: isTrainer);
    return cred;
  }

  // Email sign in
  Future<UserCredential> signInWithEmail({required String email, required String password}) async {
    return await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle({required Future<bool> Function() askIsTrainerIfNeeded}) async {
    try {
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // user aborted

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken,
      );
      final userCred = await _auth.signInWithCredential(credential);


      // Check if user doc exists
      final userRef = _db.collection('users').doc(userCred.user!.uid);
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        // doc exists, return
        return userCred;
      } else {
        // ask the app whether this user is trainer (UI callback)
        final isTrainer = await askIsTrainerIfNeeded();
        await _createUserDoc(userCred.user!, isTrainer: isTrainer);
        return userCred;
      }
    }
    catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }

  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // service method to link trainee to trainer
  Future<void> linkTraineeToTrainer({required String traineeUid, required String trainerCode}) async {
    final trainerQuery = await _db
        .collection('users')
        .where('trainerCode', isEqualTo: trainerCode)
        .where('isTrainer', isEqualTo: true)
        .limit(1)
        .get();

    if (trainerQuery.docs.isEmpty) {
      throw Exception('Invalid trainer code');
    }
    final trainerDoc = trainerQuery.docs.first;
    final trainerId = trainerDoc.id;

    // Update trainee doc
    await _db.collection('users').doc(traineeUid).update({'trainerId': trainerId});
    // Optionally add subcollection for trainees under trainer:
    await _db.collection('users').doc(trainerId)
        .collection('trainees')
        .doc(traineeUid)
        .set({'joinedAt': FieldValue.serverTimestamp()});
  }

}
