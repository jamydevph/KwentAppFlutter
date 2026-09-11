import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/resources/keys.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/data/models/app_user.dart';
import 'package:kwentappflutter/data/repositories/auth_repository.dart';
import 'package:kwentappflutter/data/repositories/supabase/failure_mapper.dart';
import 'package:kwentappflutter/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class SupabaseAuthRepositoryImpl implements AuthRepository {
  SupabaseAuthRepositoryImpl(this._service);

  final AuthService _service;

  @override
  Stream<AppUser?> get authState =>
      _service.onAuthStateChange.map((event) => _toAppUser(event.session?.user));

  @override
  AppUser? get currentUser => _toAppUser(_service.currentUser);

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) {
    return guard(() async {
      final response = await _service.signUp(
        name: name,
        email: email,
        password: password,
      );

      final user = _toAppUser(response.user);
      if (user == null) throw const ServerFailure(Strings.genericError);
      return user;
    });
  }

  @override
  Future<AppUser> login({
    required String email,
    required String password,
  }) {
    return guard(() async {
      final response = await _service.signInWithPassword(
        email: email,
        password: password,
      );

      final user = _toAppUser(response.user);
      if (user == null) {
        throw const ServerFailure(Strings.invalidCredentials);
      }
      return user;
    });
  }

  @override
  Future<void> logout() => guard(() => _service.signOut());

  @override
  Future<void> deleteAccount() => guard(() => _service.deleteAccount());

  AppUser? _toAppUser(supabase.User? user) {
    if (user == null) return null;

    return AppUser(
      id: user.id,
      email: user.email ?? '',
      name: user.userMetadata?[Keys.name] as String? ?? '',
    );
  }
}
