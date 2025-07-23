import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/constants/appwrite_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
  Future<UserModel> signInWithFacebook();
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> verifyEmail(String userId, String secret);
  Future<void> updateProfile(String name, {String? phone});
  Future<String> uploadProfileImage(String imagePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Account _account;
  final Databases _databases;
  final Storage _storage;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookAuth;

  AuthRemoteDataSourceImpl({
    required Account account,
    required Databases databases,
    required Storage storage,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookAuth,
  }) : _account = account,
       _databases = databases,
       _storage = storage,
       _googleSignIn = googleSignIn,
       _facebookAuth = facebookAuth;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      final user = await _account.get();
      await _storeUserInDatabase(user);
      return UserModel.fromAppwriteUser(user, provider: 'email');
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Email sign-in failed');
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
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );

      // Auto sign-in after registration
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );

      // Store user in database
      await _storeUserInDatabase(user);

      return UserModel.fromAppwriteUser(user, provider: 'email');
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Email sign-up failed');
    } catch (e) {
      throw ServerFailure('Unknown error occurred during sign-up');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthFailure('Google sign-in was cancelled');
      }

      await googleUser.authentication;

      await _account.createOAuth2Session(
        provider: OAuthProvider.google,
        success: 'https://your-app-callback-url/auth/google/callback',
        failure: 'https://your-app-callback-url/auth/google/callback/failure',
        scopes: ['profile', 'email'],
      );

      final user = await _account.get();

      // Update user preferences with Google profile photo
      await _account.updatePrefs(prefs: {'photoUrl': googleUser.photoUrl});

      return UserModel.fromAppwriteUser(user, provider: 'google');
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Google sign-in failed');
    } catch (e) {
      throw ServerFailure('Unknown error occurred during Google sign-in');
    }
  }

  @override
  Future<UserModel> signInWithFacebook() async {
    try {
      // Trigger Facebook sign-in flow
      final LoginResult result = await _facebookAuth.login();

      if (result.status != LoginStatus.success) {
        throw AuthFailure('Facebook sign-in was cancelled or failed');
      }

      // Get Facebook user data
      final userData = await _facebookAuth.getUserData();

      await _account.createOAuth2Session(
        provider: OAuthProvider.facebook,
        success: 'https://your-app-callback-url/auth/facebook/callback',
        failure: 'https://your-app-callback-url/auth/facebook/callback/failure',
      );

      final user = await _account.get();

      // Update user preferences with Facebook profile photo
      await _account.updatePrefs(
        prefs: {'photoUrl': userData['picture']['data']['url']},
      );

      return UserModel.fromAppwriteUser(user, provider: 'facebook');
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Facebook sign-in failed');
    } catch (e) {
      throw ServerFailure('Unknown error occurred during Facebook sign-in');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Delete all sessions
      await _account.deleteSessions();

      // Sign out from Google if it was the provider
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      // Sign out from Facebook if it was the provider
      try {
        await _facebookAuth.logOut();
      } catch (_) {}
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Sign out failed');
    } catch (e) {
      throw ServerFailure('Unknown error occurred during sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = await _account.get();
      return UserModel.fromAppwriteUser(user);
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        // User is not authenticated, return null
        return null;
      }
      throw AuthFailure(e.message ?? 'Failed to get current user');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while getting current user');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _account.createRecovery(
        email: email,
        url: 'http://localhost:8080/auth/reset-password',
      );
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while sending password reset email',
      );
    }
  }

  @override
  Future<void> verifyEmail(String userId, String secret) async {
    try {
      await _account.updateVerification(userId: userId, secret: secret);
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to verify email');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while verifying email');
    }
  }

  @override
  Future<void> updateProfile(String name, {String? phone}) async {
    try {
      await _account.updateName(name: name);

      if (phone != null) {
        await _account.updatePhone(phone: phone, password: '');
      }

      // Update user document in database
      final user = await _account.get();
      await _databases.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.usersCollection,
        documentId: user.$id,
        data: {'name': name, 'phone': phone},
      );
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to update profile');
    } catch (e) {
      throw ServerFailure('Unknown error occurred while updating profile');
    }
  }

  @override
  Future<String> uploadProfileImage(String imagePath) async {
    try {
      final uploadedFile = await _storage.createFile(
        bucketId: AppwriteConstants.profileImagesBucket,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: imagePath),
      );

      // Get file URL
      final fileUrl = _storage.getFileView(
        bucketId: AppwriteConstants.profileImagesBucket,
        fileId: uploadedFile.$id,
      );

      // Update user preferences with profile image URL
      final user = await _account.get();
      await _account.updatePrefs(
        prefs: {...user.prefs.data, 'photoUrl': fileUrl.toString()},
      );

      return fileUrl.toString();
    } on AppwriteException catch (e) {
      throw AuthFailure(e.message ?? 'Failed to upload profile image');
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while uploading profile image',
      );
    }
  }

  // Helper method to store user in database
  Future<void> _storeUserInDatabase(models.User user, {String? phone}) async {
    try {
      final userData = {
        'name': user.name,
        'email': user.email,
        'phone': phone ?? user.phone,
        'emailVerification': user.emailVerification,
        'photoUrl': user.prefs.data['photoUrl'],
        'totalInterviews': 0,
        'averageScore': 0.0,
      };

      print('Attempting to store user data: $userData');

      // Try to create new document, if it exists, update it
      try {
        await _databases.createDocument(
          databaseId: AppwriteConstants.databaseId,
          collectionId: AppwriteConstants.usersCollection,
          documentId: user.$id,
          data: userData,
        );
        print('✓ User data stored successfully in database');
      } on AppwriteException catch (e) {
        if (e.code == 409) {
          // Document already exists, update it
          await _databases.updateDocument(
            databaseId: AppwriteConstants.databaseId,
            collectionId: AppwriteConstants.usersCollection,
            documentId: user.$id,
            data: userData,
          );
          print('✓ User data updated successfully in database');
        } else {
          print('❌ AppwriteException: ${e.message} (Code: ${e.code})');
          rethrow;
        }
      }
    } catch (e) {
      // Log detailed error but don't throw as auth might still be successful
      print('❌ Failed to store user in database: $e');
      print('Database ID: ${AppwriteConstants.databaseId}');
      print('Collection ID: ${AppwriteConstants.usersCollection}');
      print('User ID: ${user.$id}');
      print(
        'Make sure all required attributes are created in the users collection!',
      );
    }
  }
}
