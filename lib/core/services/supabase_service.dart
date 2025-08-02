import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client {
    return Supabase.instance.client;
  }

  static GoTrueClient get auth {
    return client.auth;
  }

  static PostgrestQueryBuilder from(String table) {
    return client.from(table);
  }

  static RealtimeClient get realtime {
    return client.realtime;
  }

  static SupabaseStorageClient get storage {
    return client.storage;
  }

  static void dispose() {
    // No need to dispose as we're using the singleton instance
  }
}
