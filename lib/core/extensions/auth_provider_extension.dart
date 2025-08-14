import '../enums/auth_provider.dart';

extension AuthProviderExtension on AuthType {
  String get value {
    switch (this) {
      case AuthType.email:
        return 'email';
      case AuthType.google:
        return 'google';
      case AuthType.facebook:

        return 'facebook';
    }
  }

  static AuthType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'email':
        return AuthType.email;
      case 'google':
        return AuthType.google;
      case 'facebook':
        return AuthType.facebook;
      default:
        throw ArgumentError('Invalid auth provider: $value');
    }
  }
}
