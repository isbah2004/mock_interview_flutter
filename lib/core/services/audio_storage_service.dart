import 'package:appwrite/appwrite.dart';
import 'package:mock_interview/core/constants/app_secrets.dart';
import 'package:mock_interview/core/errors/failures.dart';

class AudioStorageService {
  final Storage _storage;

  AudioStorageService({required Storage storage}) : _storage = storage;

  /// Upload audio file to Appwrite Storage
  static Future<String> uploadAudioFile({
    required Storage storage,
    required String sessionId,
    required String filePath,
    required int sequenceNumber,
  }) async {
    try {
      final fileName =
          '${sessionId}_${sequenceNumber}_${DateTime.now().millisecondsSinceEpoch}.wav';

      final file = await storage.createFile(
        bucketId: AppSecrets.audioRecordingsBucket,
        fileId: ID.unique(),
        file: InputFile.fromPath(path: filePath, filename: fileName),
      );

      return storage
          .getFileView(
            bucketId: AppSecrets.audioRecordingsBucket,
            fileId: file.$id,
          )
          .toString();
    } catch (e) {
      throw ServerFailure('Failed to upload audio: $e');
    }
  }

  /// Delete audio file from Appwrite Storage
  static Future<void> deleteAudioFile({
    required Storage storage,
    required String fileId,
  }) async {
    try {
      await storage.deleteFile(
        bucketId: AppSecrets.audioRecordingsBucket,
        fileId: fileId,
      );
    } catch (e) {
      throw ServerFailure('Failed to delete audio: $e');
    }
  }

  /// Upload audio file instance method
  Future<String> uploadAudio({
    required String sessionId,
    required String filePath,
    required int sequenceNumber,
  }) async {
    return uploadAudioFile(
      storage: _storage,
      sessionId: sessionId,
      filePath: filePath,
      sequenceNumber: sequenceNumber,
    );
  }

  /// Delete audio file instance method
  Future<void> deleteAudio(String fileId) async {
    return deleteAudioFile(storage: _storage, fileId: fileId);
  }

  /// Get audio file URL
  String getAudioUrl(String fileId) {
    return _storage
        .getFileView(bucketId: AppSecrets.audioRecordingsBucket, fileId: fileId)
        .toString();
  }

  /// Get audio file download URL
  String getAudioDownloadUrl(String fileId) {
    return _storage
        .getFileDownload(
          bucketId: AppSecrets.audioRecordingsBucket,
          fileId: fileId,
        )
        .toString();
  }
}
