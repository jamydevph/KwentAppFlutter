import 'package:kwentappflutter/data/models/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> get authState;

  AppUser? get currentUser;

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<void> deleteAccount();
}
