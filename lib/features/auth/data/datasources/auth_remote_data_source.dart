import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mock_interview/core/errors/exceptions.dart';
import 'dart:developer';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:mock_interview/core/errors/failures.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmail(String email, String password);
  Future<UserModel> signUpWithEmail(String email, String password, String name);
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  supabase.Session? get currentUserSession;
  Future<void> sendPasswordResetEmail(String email);
  Future<void> verifyEmail(String userId, String secret);
  Future<void> updateProfile(String name);
  Future<String> uploadProfileImage(String imagePath);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supabase.SupabaseClient _supabaseClient;
  final Databases _databases;
  final Storage _storage;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required supabase.SupabaseClient supabaseClient,
    required Databases databases,
    required Storage storage,
    required GoogleSignIn googleSignIn,
  }) : _supabaseClient = supabaseClient,
       _databases = databases,
       _storage = storage,
        _googleSignIn = googleSignIn;

  @override
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final currentUser = response.user;
      if (currentUser == null) {
        throw AuthFailure('Invalid email or password');
      }
      await _storeUserInDatabase(currentUser);
      return UserModel.fromAppwriteUser(currentUser, provider: 'email');
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
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
      // First create user
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        
        data: {'name': name, 'email': email},
      );

      if (response.user == null) {
        throw AuthFailure('Sign-up failed, user not created');
      }

      // Store user in database immediately after signup
      await _storeUserInDatabase(response.user!);

      return UserModel.fromAppwriteUser(response.user!, provider: 'email');
    } on AuthException catch (e) {
      log('Supabase AuthException: ${e.message}');
      throw AuthFailure(e.message);
    } catch (e) {
      log('Error during sign-up: $e');
      throw ServerFailure('Unknown error occurred during sign-up');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
 final googleAccount = await _googleSignIn.authenticate();
final idToken = googleAccount.authentication.idToken;

if (idToken == null) {
  throw AuthFailure('Google sign-in failed: No ID token received');
}
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: supabase.OAuthProvider.google,
        idToken: idToken,
      );
if (response.user == null) {
        throw AuthFailure('Google sign-in failed: User not found');
      }
    
      _storeUserInDatabase(response.user!);

      return UserModel.fromAppwriteUser(response.user!, provider: 'google');
    } on AuthException catch (e) {
      throw AuthFailure(e.message );
    } catch (e) {
      log( 'Error during Google sign-in: $e');
      throw ServerFailure('Unknown error occurred during Google sign-in');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Delete all sessions
      await _supabaseClient.auth.signOut();

      // Sign out from Google if it was the provider
      try {
        // await _googleSignIn.signOut();
      } catch (_) {}

      // Sign out from Facebook if it was the provider
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unknown error occurred during sign out');
    }
  }

  @override
  supabase.Session? get currentUserSession =>
      _supabaseClient.auth.currentSession;
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _supabaseClient.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while sending password reset email',
      );
    }
  }

  @override
  Future<void> verifyEmail(String userId, String secret) async {
    try {
      await _supabaseClient.auth.verifyOTP(
        type: supabase.OtpType.email,
        token: secret,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure('Unknown error occurred while verifying email');
    }
  }

  @override
  Future<void> updateProfile(String name) async {
    try {
      await _supabaseClient.auth.updateUser(
        supabase.UserAttributes(data: {'name': name}),
      );

      // Update user document in database
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw AuthFailure('User not found');
      }
      await _databases.updateDocument(
        databaseId: AppSecrets.databaseId,
        collectionId: AppSecrets.usersCollection,
        documentId: user.id,
        data: {'name': name},
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
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

      // Update user preferences with profile image URL
      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        throw AuthFailure('User not found');
      }
      await _supabaseClient.auth.updateUser(
        supabase.UserAttributes(data: {'photoUrl': fileUrl.toString()}),
      );

      return fileUrl.toString();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw ServerFailure(
        'Unknown error occurred while uploading profile image',
      );
    }
  }

  // Helper method to store user in database
  Future<void> _storeUserInDatabase(supabase.User user) async {
    try {
      final userData = {
        'id': user.id,

        'name': user.userMetadata!['name'],
        'email': user.email,
        'photoUrl': user.userMetadata?['photoUrl'],
        'totalInterviews': 0,
        'averageScore': 0.0,
      };

      log('Attempting to store user data: $userData');

      // Try to create new document, if it exists, update it
      try {
        await _databases.createDocument(
          databaseId: AppSecrets.databaseId,
          collectionId: AppSecrets.usersCollection,
          documentId: user.id,
          data: userData,
        );
        log('✓ User data stored successfully in database');
      } on AppwriteException catch (e) {
        if (e.code == 409) {
          // Document already exists, update it
          await _databases.updateDocument(
            databaseId: AppSecrets.databaseId,
            collectionId: AppSecrets.usersCollection,
            documentId: user.id,
            data: userData,
          );
          log('✓ User data updated successfully in database');
        } else {
          log('❌ AuthException: ${e.message} (Code: ${e.code})');
          rethrow;
        }
      }
    } catch (e) {
      // Log detailed error but don't throw as auth might still be successful
      log('❌ Failed to store user in database: $e');
      log('Database ID: ${AppSecrets.databaseId}');
      log('Collection ID: ${AppSecrets.usersCollection}');
      log('User ID: ${user.id}');
      log(
        'Make sure all required attributes are created in the users collection!',
      );
    }
  }
}
