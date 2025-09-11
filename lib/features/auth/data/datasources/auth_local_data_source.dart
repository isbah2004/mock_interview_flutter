
import 'package:get_storage/get_storage.dart';
import 'package:mock_interview/core/constants/storage_key.dart';
import 'package:mock_interview/core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getLastUser();
  Future<void> clearCache();
  Future<void> updateUser(UserModel user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
final GetStorage storage;

  AuthLocalDataSourceImpl(this.storage);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {

      storage.write(StorageKeys.userKey, user.toJson());
     
    } catch (e) {
      throw CacheException('Failed to cache user data');
    }
  }

  @override
  Future<UserModel?> getLastUser() async {
    try {
      final userData = storage.read(StorageKeys.userKey);
      if (userData != null) {
        return UserModel.fromJson(userData);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user data');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await storage.erase();
    } catch (e) {
      throw CacheException('Failed to clear cache');
    }
  }
  
  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await storage.write(StorageKeys.userKey, user.toJson());
    } catch (e) {
      throw CacheException('Failed to update user data');
    }
    
  }
}