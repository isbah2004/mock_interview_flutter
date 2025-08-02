import 'package:appwrite/appwrite.dart';
import '../constants/app_secrets.dart';

class AppwriteService {
  static Client? _client;
  static Account? _account;
  static Databases? _databases;
  static Storage? _storage;
  static Realtime? _realtime;

  static Client get client {
    _client ??= Client()
        .setEndpoint(AppSecrets.endpoint)
        .setProject(AppSecrets.projectId)
        .setSelfSigned(status: true); // Only for development
    return _client!;
  }

  static Account get account {
    _account ??= Account(client);
    return _account!;
  }

  static Databases get databases {
    _databases ??= Databases(client);
    return _databases!;
  }

  static Storage get storage {
    _storage ??= Storage(client);
    return _storage!;
  }

  static Realtime get realtime {
    _realtime ??= Realtime(client);
    return _realtime!;
  }

  static void dispose() {
    _client = null;
    _account = null;
    _databases = null;
    _storage = null;
    _realtime = null;
  }
}
