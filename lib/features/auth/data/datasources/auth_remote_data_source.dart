import 'package:appwrite/appwrite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithFacebook();
  Future<void> signOut();
  User? get currentUser;
  Future<void> sendPasswordResetEmail(String email);
  Future<void> verifyEmail(String otp);
  Future<void> updateProfile(String name);
  Future<String> uploadProfileImage(String imagePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final Databases _databases;
  final Storage _storage;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required Databases databases,
    required Storage storage,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookAuth,
  }) : _firebaseAuth = firebaseAuth,
       _databases = databases,
       _storage = storage,
       _facebookAuth = facebookAuth,
       _googleSignIn = googleSignIn;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final currentUser = credential.user;
      if (currentUser == null) {
        throw AuthFailure('Invalid email or password');
      }
      await _storeUserInDatabase(currentUser);
      return UserModel.fromFirebaseUser(currentUser, provider: 'email');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Sign-in failed');
    } catch (e) {
      log('Error during sign-in: $e');
      throw ServerFailure('Unknown error occurred during sign-in');
    }
  }

  @override
  Future<UserModel> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Create user with Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final currentUser = credential.user;
      if (currentUser == null) {
        throw AuthFailure('Sign-up failed, user not created');
      }

      // Update the user's display name
      await currentUser.updateDisplayName(name);

      // Store user in database immediately after signup
      await _storeUserInDatabase(currentUser);

      return UserModel.fromFirebaseUser(currentUser, provider: 'email');
    } on FirebaseAuthException catch (e) {
      log('Firebase AuthException: ${e.message}');
      throw AuthFailure(e.message ?? 'Sign-up failed');
    } catch (e) {
      log('Error during sign-up: $e');
      throw ServerFailure('Unknown error occurred during sign-up');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      log('🔍 Google sign-in attempt');

      // Start the authentication process
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      log('🔍 Google user obtained: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      log(
        '🔍 Google auth obtained - ID Token: ${googleAuth.idToken != null ? "Present" : "Missing"}',
      );

      if (googleAuth.idToken == null) {
        throw AuthFailure(
          'Google sign-in failed: No ID token received. Please ensure Google Sign-In is properly configured in Firebase Console.',
        );
      }

      log('🔍 Creating Firebase credential');

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      log('🔍 Firebase credential created, attempting sign-in');

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw AuthFailure('Google sign-in failed: User not found');
      }

      log(
        '🔍 Firebase sign-in successful for user: ${userCredential.user!.email}',
      );

      await _storeUserInDatabase(userCredential.user!);

      return UserModel.fromFirebaseUser(
        userCredential.user!,
        provider: 'google',
      );
    } on FirebaseAuthException catch (e) {
      log('🚨 Firebase auth error: ${e.code} - ${e.message}');
      String errorMessage = 'Google sign-in failed';

      switch (e.code) {
        case 'invalid-credential':
          errorMessage =
              'Invalid Google credentials. Please ensure:\n'
              '1. Google Sign-In is enabled in Firebase Console\n'
              '2. SHA-1 fingerprint is added to Firebase\n'
              '3. Latest google-services.json is downloaded\n'
              '4. App package name matches Firebase configuration';
          break;
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with a different sign-in method';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google sign-in is not enabled in Firebase Console';
          break;
        case 'user-disabled':
          errorMessage = 'This account has been disabled';
          break;
        case 'user-not-found':
          errorMessage = 'No account found with these credentials';
          break;
        case 'wrong-password':
          errorMessage = 'Invalid credentials provided';
          break;
        case 'network-request-failed':
          errorMessage = 'Network error. Please check your connection';
          break;
        default:
          errorMessage = e.message ?? 'Google sign-in failed';
      }

      throw AuthFailure(errorMessage);
    } catch (e) {
      log('🚨 Unexpected Google sign-in error: $e');
      throw ServerFailure('Unknown error occurred during Google sign-in: $e');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      log('🔍 Facebook login attempt');

      // Attempt Facebook login
      final facebookLoginResult = await _facebookAuth.login();

      log('🔍 Facebook login result status: ${facebookLoginResult.status}');
      log(
        '🔍 Access token available: ${facebookLoginResult.accessToken != null}',
      );

      if (facebookLoginResult.status == LoginStatus.cancelled) {
        throw AuthFailure('Facebook sign-in was cancelled');
      }

      if (facebookLoginResult.status == LoginStatus.failed) {
        final errorMessage =
            facebookLoginResult.message ?? 'Facebook sign-in failed';
        log('🚨 Facebook login failed: $errorMessage');
        throw AuthFailure(errorMessage);
      }

      // Check if we have an access token
      final accessToken = facebookLoginResult.accessToken;
      if (accessToken == null) {
        throw AuthFailure('Facebook sign-in failed: No access token received');
      }

      log('🔍 Facebook access token: ${accessToken.tokenString}');

      // Create Firebase credential from Facebook token
      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      // Sign in with Firebase using Facebook credential
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final currentUser = userCredential.user;
      if (currentUser == null) {
        throw AuthFailure(
          'Facebook sign-in failed: Unable to authenticate with server',
        );
      }

      log('🔍 Facebook sign-in successful - User ID: ${currentUser.uid}');
      log('🔍 User email: ${currentUser.email}');
      log('🔍 User display name: ${currentUser.displayName}');

      // Store user in database
      await _storeUserInDatabase(currentUser);

      return UserModel.fromFirebaseUser(currentUser, provider: 'facebook');
    } on FirebaseAuthException catch (e) {
      log('🚨 Firebase auth error: ${e.message}');
      throw AuthFailure(e.message ?? 'Facebook sign-in failed');
    } catch (e) {
      log('🚨 Unexpected Facebook sign-in error: $e');
      throw ServerFailure('Unknown error occurred during Facebook sign-in');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Sign out from Google if it was the provider
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // Sign out from Facebook if it was the provider
      try {
        await _facebookAuth.logOut();
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Sign-out failed');
    } catch (e) {
      throw ServerFailure('Unknown error occurred during sign out');
    }
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while sending password reset email',
      );
    }
  }

  @override
  Future<void> verifyEmail(String otp) async {
    try {
      // Firebase doesn't use OTP for email verification in the same way as Supabase
      // Instead, you would typically use currentUser.sendEmailVerification()
      // and then check currentUser.emailVerified
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Email verification failed');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while verifying email');
    }
  }

  @override
  Future<void> updateProfile(String name) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthFailure('User not found');
      }

      await user.updateDisplayName(name);

      // Update user document in database
      await _databases.updateDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.usersCollection,
        documentId: user.uid,
        data: {'name': name},
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Profile update failed');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while updating profile');
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final uploadedFile = await _storage.createFile(
        bucketId: AppSecrets.profileImagesBucket,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: imagePath),
      );

      // Get file URL
      final fileUrl = _storage.getFileView(
        bucketId: AppSecrets.profileImagesBucket,
        fileId: uploadedFile.$id,
      );

      // Update user photo URL
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthFailure('User not found');
      }
      await user.updatePhotoURL(fileUrl.toString());

      return fileUrl.toString();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(e.message ?? 'Profile image upload failed');
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while uploading profile image',
      );
    }
  }

  // Helper method to store user in database
  Future<void> _storeUserInDatabase(User user) async {
    try {
      final userData = {
        'id': user.uid,
        'name': user.displayName ?? user.email?.split('@')[0] ?? 'User',
        'email': user.email,
        'photoUrl': user.photoURL,
        'totalInterviews': 0,
        'averageScore': 0.0,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      log('Attempting to store user data: $userData');

      // Try to create new document, if it exists, update it
      try {
        await _databases.createDocument(
          databaseId: AppSecrets.databaseId,
          collectionId: AppSecrets.usersCollection,
          documentId: user.uid,
          data: userData,
        );
        log('✓ User data stored successfully in database');
      } on AppwriteException catch (e) {
        if (e.code == 409) {
          // Document already exists, update it
          await _databases.updateDocument(
            databaseId: AppSecrets.databaseId,
            collectionId: AppSecrets.usersCollection,
            documentId: user.uid,
            data: userData,
          );
          log('✓ User data updated successfully in database');
        } else {
          log('❌ AppwriteException: ${e.message} (Code: ${e.code})');
          rethrow;
        }
      }
    } catch (e) {
      // Log detailed error but don't throw as auth might still be successful
      log('❌ Failed to store user in database: $e');
      log('Database ID: ${AppSecrets.databaseId}');
      log('Collection ID: ${AppSecrets.usersCollection}');
      log('User ID: ${user.uid}');
      log(
        'Make sure all required attributes are created in the users collection!',
      );
    }
  }
}
