import 'package:permission_handler/permission_handler.dart';
abstract class PermissionService {
  Future<bool> requestMicrophonePermission();
  Future<bool> requestSpeechPermission();
}


class FlutterPermissionService implements PermissionService {
  @override
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  @override
  Future<bool> requestSpeechPermission() async {
    final status = await Permission.speech.request();
    return status.isGranted;
  }
}
