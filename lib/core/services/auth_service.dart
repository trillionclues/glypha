import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glypha/core/failure/failure.dart';
import 'package:glypha/features/auth/domain/entities/user_entity.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'auth_service.g.dart';

@riverpod
AuthService authService(Ref ref) {
  return AuthService(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
    GoogleSignIn(
      scopes: ['email', 'profile'],
    ),
  );
}

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthService(this._auth, this._firestore, this._googleSignIn);

  Stream<UserEntity?> get authChanges {
    return _auth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _getUserEntity(firebaseUser);
    });
  }

  User? get currentUser => _auth.currentUser;

  Future<UserEntity?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure.cancelledByUser();
      }

      final googleAuth = await googleUser.authentication;
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredentials = await _auth.signInWithCredential(credentials);
      final user = userCredentials.user!;

      // Check if user document exists, create if not
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        await _createUserDocument(user);
      }

      return await _getUserEntity(user);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw const AuthFailure.serverError();
    }
  }

  Future<UserEntity> signInWithApple() async {
    try {
      if (!await SignInWithApple.isAvailable()) {
        throw const AuthFailure.serverError();
      }

      final appleCredential =
          await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);

      final OAuthCredential oAuthCredential =
          OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oAuthCredential);
      final user = userCredential.user!;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        String? displayName = user.displayName;

        if (displayName == null || displayName.isEmpty) {
          final givenName = appleCredential.givenName ?? '';
          final familyName = appleCredential.familyName ?? '';
          if (givenName.isNotEmpty || familyName.isNotEmpty) {
            displayName = '$givenName $familyName'.trim();
            await user.updateDisplayName(displayName);
          }
        }
        await _createUserDocument(user);
      }

      return _getUserEntity(user);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw const AuthFailure.cancelledByUser();
      } else {
        throw const AuthFailure.serverError();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw const AuthFailure.serverError();
    }
  }

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw const AuthFailure.serverError();
    }
  }

  Future<bool> needsAdditionalDetails(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return true;

      final data = userDoc.data()!;
      // If explicit flag is present, use it
      if (data['isOnboardingCompleted'] == true) return false;

      // Fallback to checking fields (legacy or if flag missing)
      return data['phoneNumber'] == null ||
          data['educationLevel'] == null ||
          (data['interests'] as List?)?.isEmpty != false ||
          data['dailyGoal'] == null ||
          data['learningStyle'] == null;
    } catch (e) {
      return true;
    }
  }

  Future<void> updateAdditionalDetails({
    required String userId,
    List<String>? interests,
    String? dailyGoal,
    String? learningStyle,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        if (interests != null) 'interests': interests,
        'dailyGoal': dailyGoal,
        'learningStyle': learningStyle,
        'isOnboardingCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw const AuthFailure.serverError();
    }
  }

  Future<UserEntity> _getUserEntity(User firebaseUser) async {
    final userDoc =
        await _firestore.collection('users').doc(firebaseUser.uid).get();

    if (userDoc.exists) {
      final data = userDoc.data()!;
      return UserEntity(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName,
        photoUrl: firebaseUser.photoURL,
        isEmailVerified: firebaseUser.emailVerified,
        interests: data['interests'] != null
            ? List<String>.from(data['interests'])
            : null,
        dailyGoal: data['dailyGoal'],
        learningStyle: data['learningStyle'],
        isOnboardingCompleted: data['isOnboardingCompleted'] ?? false,
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : null,
      );
    }

    // Return basic user entity if no Firestore doc
    return UserEntity(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified,
    );
  }

  Future<void> _createUserDocument(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'id': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'isEmailVerified': user.emailVerified,
      'interests': [],
      'dailyGoal': null,
      'learningStyle': null,
      'isOnboardingCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  AuthFailure _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthFailure.invalidCredentials();
      case 'email-already-in-use':
        return const AuthFailure.emailAlreadyInUse();
      case 'weak-password':
        return const AuthFailure.weakPassword();
      case 'network-request-failed':
        return const AuthFailure.networkError();
      case 'user-disabled':
        return const AuthFailure.userNotFound();
      case 'invalid-email':
        return const AuthFailure.invalidEmail();
      default:
        return const AuthFailure.serverError();
    }
  }
}
