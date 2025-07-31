import 'package:get_it/get_it.dart';
import 'package:appwrite/appwrite.dart';
import 'package:mock_interview/core/constants/appwrite_constants.dart';
final GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Register Appwrite Client
  getIt.registerLazySingleton<Client>(() {
    final client = Client();
    try {
      client
        ..setEndpoint(AppwriteConstants.endpoint)
        ..setProject(AppwriteConstants.projectId);
      return client;
    } catch (e) {
      // Return a mock client if configuration fails
      return Client();
    }
  });

  // Register Appwrite Account
  getIt.registerLazySingleton<Account>(() {
    try {
      return Account(getIt<Client>());
    } catch (e) {
      // Return a mock account if Appwrite setup fails
      return MockAccount();
    }
  });

  // Register Appwrite Databases
  getIt.registerLazySingleton<Databases>(() {
    try {
      return Databases(getIt<Client>());
    } catch (e) {
      // Return a mock databases if Appwrite setup fails
      return MockDatabases();
    }
  });

  
}

// Mock Account class for testing purposes
class MockAccount implements Account {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #get) {
      // Simulate unauthenticated user for now
      throw Exception('Not authenticated');
    }
    return super.noSuchMethod(invocation);
  }
}

// Mock Databases class for testing purposes
class MockDatabases implements Databases {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}
