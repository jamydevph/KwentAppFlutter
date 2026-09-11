import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/events/app_events.dart';
import 'package:kwentappflutter/data/models/app_user.dart';
import 'package:kwentappflutter/data/models/profile.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:kwentappflutter/data/repositories/auth_repository.dart';
import 'package:kwentappflutter/data/repositories/profile_repository.dart';
import 'package:kwentappflutter/data/services/profile_cache_service.dart';
import 'package:kwentappflutter/ui/auth/auth_form_state.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._repository, this._profiles, this._cache, this._events) {
    _user = _repository.currentUser;
    _subscription = _repository.authState.listen(_onAuthChanged);
    _eventSubscription = _events.events.listen(_onEvent);
    _restoreCachedProfile();
    reloadProfile();
  }

  final AuthRepository _repository;
  final ProfileRepository _profiles;
  final ProfileCacheService _cache;
  final AppEventBus _events;
  late final StreamSubscription<AppUser?> _subscription;
  late final StreamSubscription<DomainEvent> _eventSubscription;

  AppUser? _user;
  Profile? _profile;
  AuthFormState _formState = const AuthFormIdle();

  AppUser? get user => _user;
  Profile? get profile => _profile;
  bool get isSignedIn => _user != null;

  void _onEvent(DomainEvent event) {
    switch (event) {
      case ProfileChanged(:final profile):
        if (profile.id != _user?.id) return;
        _profile = profile;
        notifyListeners();
        _cache.write(profile);

      case PostCreated():
      case PostUpdated():
      case PostDeleted():
      case CommentCountChanged():
        break;
    }
  }

  Future<void> reloadProfile() async {
    final id = _user?.id;
    if (id == null) return;

    final Profile profile;

    try {
      profile = await _profiles.fetchProfile(id);
    } catch (_) {
      return;
    }

    if (_user?.id != id) return;

    _profile = profile;
    notifyListeners();
    await _cache.write(profile);
  }

  Future<void> _restoreCachedProfile() async {
    final id = _user?.id;
    if (id == null || _profile != null) return;

    final cached = await _cache.read(id);
    if (cached == null || _profile != null || _user?.id != id) return;

    _profile = cached;
    notifyListeners();
  }

  AuthFormState get formState => _formState;
  bool get isBusy => _formState is AuthFormSubmitting;

  String? get formError =>
      _formState is AuthFormFailed ? (_formState as AuthFormFailed).message : null;

  void resetForm() {
    if (_formState is AuthFormIdle) return;
    _set(const AuthFormIdle());
  }

  Future<AuthFormState> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.register(name: name, email: email, password: password),
      Strings.accountCreatedMessage,
    );
  }

  Future<AuthFormState> login({
    required String email,
    required String password,
  }) {
    return _run(
      () => _repository.login(email: email, password: password),
      Strings.signedInMessage,
    );
  }

  Future<bool> logout() async {
    if (isBusy) return false;
    _set(const AuthFormSubmitting());

    try {
      await _repository.logout();
      _user = null;
      _set(const AuthFormIdle());
      return true;
    } catch (error) {
      _set(AuthFormFailed(failureMessage(error)));
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    if (isBusy) return false;
    _set(const AuthFormSubmitting());

    try {
      await _repository.deleteAccount();
      _user = null;
      _set(const AuthFormIdle());
      return true;
    } catch (error) {
      _set(AuthFormFailed(failureMessage(error)));
      return false;
    }
  }

  Future<AuthFormState> _run(
    Future<AppUser> Function() action,
    String successMessage,
  ) async {
    if (isBusy) return _formState;
    _set(const AuthFormSubmitting());

    try {
      _user = await action();
      _set(AuthFormSucceeded(successMessage));
    } catch (error) {
      _set(AuthFormFailed(failureMessage(error)));
    }

    return _formState;
  }

  void _onAuthChanged(AppUser? user) {
    if (_user == user) return;
    _user = user;
    _profile = null;
    notifyListeners();

    if (user == null) {
      _cache.clear();
      return;
    }

    _restoreCachedProfile();
    reloadProfile();
  }

  void _set(AuthFormState next) {
    _formState = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _eventSubscription.cancel();
    super.dispose();
  }
}
