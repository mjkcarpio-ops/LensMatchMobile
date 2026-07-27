import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/customer_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of auth state changes (logged in / logged out)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current logged-in user
  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password, validating customer role and active status
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await verifyCustomerAuthorization(user.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw getReadableAuthError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  /// Verifies that the user with [uid] exists in CUSTOMERS collection, has role 'customer', and isActive is true.
  /// If unauthorized, signs out immediately and throws a readable error.
  Future<void> verifyCustomerAuthorization(String uid) async {
    try {
      final doc = await _firestore.collection('CUSTOMERS').doc(uid).get();

      if (!doc.exists) {
        await _auth.signOut();
        throw 'This account is not registered as a customer.';
      }

      final data = doc.data();
      final role = data?['role'];
      final isActive = data?['isActive'] ?? true;

      if (role != 'customer') {
        await _auth.signOut();
        throw 'This account is not registered as a customer.';
      }

      if (!isActive) {
        await _auth.signOut();
        throw 'This account has been deactivated. Please contact support.';
      }
    } catch (e) {
      if (e is String) rethrow;
      await _auth.signOut();
      throw 'Authorization check failed. Please log in again.';
    }
  }

  /// Fetch Customer profile document from Firestore
  Future<CustomerModel?> getCustomerProfile(String uid) async {
    try {
      final doc = await _firestore.collection('CUSTOMERS').doc(uid).get();
      if (doc.exists) {
        return CustomerModel.fromFirestore(doc);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Update customer profile details in Cloud Firestore and Firebase Auth
  Future<void> updateCustomerProfile({
    required String uid,
    required String fullName,
    String? phoneNumber,
    String? address,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.uid == uid) {
        await user.updateDisplayName(fullName.trim());
      }

      final updateData = <String, dynamic>{
        'fullName': fullName.trim(),
      };
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber.trim();
      if (address != null) updateData['address'] = address.trim();

      await _firestore.collection('CUSTOMERS').doc(uid).update(updateData);
    } catch (e) {
      throw 'Failed to update profile. Please try again.';
    }
  }


  /// Register customer account and create profile in CUSTOMERS collection.
  /// Rolls back Auth user creation if Firestore profile creation fails.
  Future<UserCredential> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    UserCredential? credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(fullName.trim());

        // Create Customer document in Cloud Firestore
        try {
          await _firestore.collection('CUSTOMERS').doc(user.uid).set({
            'uid': user.uid,
            'fullName': fullName.trim(),
            'email': email.trim(),
            'role': 'customer',
            'isActive': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } catch (firestoreError) {
          // Atomic Rollback: Delete newly created Auth account if profile creation failed
          try {
            await user.delete();
          } catch (_) {}
          throw 'Failed to create customer profile. Registration rolled back.';
        }
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw getReadableAuthError(e);
    } catch (e) {
      if (e is String) rethrow;
      throw 'An unexpected error occurred during registration.';
    }
  }

  /// Password Reset
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw getReadableAuthError(e);
    } catch (e) {
      throw 'Failed to send password reset email.';
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Convert Firebase Auth exception codes to clean user-friendly messages
  static String getReadableAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'The password provided is too weak. Please use at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password. Please check your credentials.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection error. Check your internet connection.';
      case 'channel-error':
        return 'Please fill in all required fields.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}

