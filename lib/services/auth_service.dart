// lib/services/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerStationOwner({
    required String name,
    required String email,
    required String mobile,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = userCredential.user;
      await user?.sendEmailVerification();

      final uid = user!.uid;

      await _firestore.collection('stationOwners').doc(uid).set({
        'name': name.trim(),
        'email': email.trim(),
        'mobile': mobile.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'verified': false,
      });

      await _firestore.collection('users').doc(uid).set({
        'email': email.trim(),
        'role': 'stationOwner',
      });

      return null; // success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') return "Password is too weak";
      if (e.code == 'email-already-in-use') return "Email already in use";
      if (e.code == 'invalid-email') return "Invalid email format";
      return "Authentication failed";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }
}
