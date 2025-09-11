import 'package:appwrite/appwrite.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mock_interview/core/enums/auth_provider.dart';
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
  Future<Map<String, dynamic>?> getUserFromAppwrite(String userId);
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
      return UserModel.fromFirebaseUser(currentUser, provider: AuthType.email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_authExceptionHandler(e));
    } catch (e) {
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
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final currentUser = credential.user;
      if (currentUser == null) {
        throw AuthFailure('Sign-up failed, user not created');
      }

      // Update the display name and wait for completion
      await currentUser.updateDisplayName(name);

      // Reload the user to ensure the display name is updated
      await currentUser.reload();
      final updatedUser = _firebaseAuth.currentUser;

      // Store user in database with the name we just set
      await _storeUserInDatabase(updatedUser ?? currentUser, 'email', name);

      return UserModel.fromFirebaseUser(
        updatedUser ?? currentUser,
        provider: AuthType.email,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_authExceptionHandler(e));
    } catch (e) {
      throw ServerFailure('Unknown error occurred during sign-up');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw AuthFailure(
          'Google sign-in failed: No ID token received. Please ensure Google Sign-In is properly configured in Firebase Console.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw AuthFailure('Google sign-in failed: User not found');
      }
      await _storeUserInDatabase(userCredential.user!, 'google');

      return UserModel.fromFirebaseUser(
        userCredential.user!,
        provider: AuthType.google,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_authExceptionHandler(e));
    } catch (e) {
      throw ServerFailure('Unknown error occurred during Google sign-in: $e');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      final facebookLoginResult = await _facebookAuth.login();

      if (facebookLoginResult.status == LoginStatus.cancelled) {
        throw AuthFailure('Facebook sign-in was cancelled');
      }

      if (facebookLoginResult.status == LoginStatus.failed) {
        final errorMessage =
            facebookLoginResult.message ?? 'Facebook sign-in failed';
        throw AuthFailure(errorMessage);
      }

      final accessToken = facebookLoginResult.accessToken;
      if (accessToken == null) {
        throw AuthFailure('Facebook sign-in failed: No access token received');
      }

      final credential = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      final currentUser = userCredential.user;
      if (currentUser == null) {
        throw AuthFailure(
          'Facebook sign-in failed: Unable to authenticate with server',
        );
      }

      await _storeUserInDatabase(currentUser, 'facebook');

      return UserModel.fromFirebaseUser(
        currentUser,
        provider: AuthType.facebook,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_authExceptionHandler(e));
    } catch (e) {
      throw ServerFailure('Unknown error occurred during Facebook sign-in');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();

      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      try {
        await _facebookAuth.logOut();
      } catch (_) {}
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_authExceptionHandler(e));
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
      throw AuthFailure(_authExceptionHandler(e));
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while sending password reset email',
      );
    }
  }

  @override
  Future<void> verifyEmail(String otp) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_authExceptionHandler(e));
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

      await _databases.updateDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.usersCollection,
        documentId: user.uid,
        data: {'name': name},
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_authExceptionHandler(e));
    } on AppwriteException catch (e) {
      throw ServerFailure(_appwriteExceptionHandler(e));
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
      final fileUrl = _storage.getFileView(
        bucketId: AppSecrets.profileImagesBucket,
        fileId: uploadedFile.$id,
      );

      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw AuthFailure('User not found');
      }
      await user.updatePhotoURL(fileUrl.toString());

      return fileUrl.toString();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_authExceptionHandler(e));
    } on AppwriteException catch (e) {
      throw ServerFailure(_appwriteExceptionHandler(e));
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while uploading profile image',
      );
    }
  }

  Future<void> _storeUserInDatabase(
    User user,
    String provider, [
    String? explicitName,
  ]) async {
    try {
      // First check if the user document already exists
      Map<String, dynamic>? existingUserData;
      try {
        final existingDoc = await _databases.getDocument(
          databaseId: AppSecrets.databaseId,
          collectionId: AppSecrets.usersCollection,
          documentId: user.uid,
        );
        existingUserData = existingDoc.data;
        log('Found existing user data: $existingUserData');
      } on AppwriteException catch (e) {
        if (e.code == 404) {
          // Document doesn't exist, we'll create it
          log('User document does not exist, will create new');
          existingUserData = null;
        } else {
          throw ServerFailure(_appwriteExceptionHandler(e));
        }
      }

      // Use explicit name if provided, otherwise fall back to user.displayName or email
      final userName =
          explicitName ??
          user.displayName ??
          user.email?.split('@')[0] ??
          'User';

      if (existingUserData != null) {
        // User exists, only update basic profile info without resetting stats
        final updateData = {
          'name': userName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'updatedAt': DateTime.now().toIso8601String(),
          'provider': provider,
        };

        log('Updating existing user with: $updateData');

        await _databases.updateDocument(
          databaseId: AppSecrets.databaseId,
          collectionId: AppSecrets.usersCollection,
          documentId: user.uid,
          data: updateData,
        );
      } else {
        // User doesn't exist, create new document with default stats
        final userData = {
          'id': user.uid,
          'name': userName,
          'email': user.email,
          'photoUrl': user.photoURL,
          'totalInterviews': 0,
          'averageScore': 0.0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
          'voiceInterviews': 0,
          'mcqInterviews': 0,
          'provider': provider,
        };

        log('Creating new user with: $userData');

        await _databases.createDocument(
          databaseId: AppSecrets.databaseId,
          collectionId: AppSecrets.usersCollection,
          documentId: user.uid,
          data: userData,
        );
      }
    } catch (e) {
      throw ServerFailure('Failed to store user in database: $e');
    }
  }

  String _authExceptionHandler(FirebaseAuthException e) {
    switch (e.code) {
      case 'account-exists-with-different-credential':
        return 'An account already exists with a different sign-in method';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled in Firebase Console';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with these credentials';
      case 'wrong-password':
        return 'Invalid credentials provided';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }

  String _appwriteExceptionHandler(AppwriteException e) {
    switch (e.code) {
      case 409:
        return 'A user with this ID already exists.';
      case 401:
        return 'Unauthorized request. Please check your credentials.';
      case 404:
        return 'Requested resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return e.message ?? 'Appwrite error occurred.';
    }
  }

  /// Get user data from Appwrite
  @override
  Future<Map<String, dynamic>?> getUserFromAppwrite(String userId) async {
    try {
      final document = await _databases.getDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.usersCollection,
        documentId: userId,
      );
      return document.data;
    } on AppwriteException catch (e) {
      if (e.code == 404) {
        // User document doesn't exist in Appwrite
        return null;
      }
      throw ServerFailure(_appwriteExceptionHandler(e));
    } catch (e) {
      throw ServerFailure('Failed to get user from Appwrite: $e');
    }
  }
}
