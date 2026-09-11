import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' show ClientException;
import 'package:kwentappflutter/core/error/failure.dart';
import 'package:kwentappflutter/core/resources/strings.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Failure mapError(Object error) {
  return switch (error) {
    Failure() => error,
    AuthException() => const ServerFailure(Strings.invalidCredentials),
    FunctionException() => const ServerFailure(Strings.genericError),
    StorageException() => const StorageFailure(Strings.storageError),
    PostgrestException(:final code) when _isRlsDenial(code) =>
      const ServerFailure(Strings.notAllowed),
    PostgrestException() => const ServerFailure(Strings.genericError),
    SocketException() => const NetworkFailure(Strings.networkError),
    TimeoutException() => const NetworkFailure(Strings.networkError),
    ClientException() => const NetworkFailure(Strings.networkError),
    _ => const UnknownFailure(Strings.genericError),
  };
}

bool _isRlsDenial(String? code) => code == '42501' || code == 'PGRST301';

Future<T> guard<T>(Future<T> Function() action) async {
  try {
    return await action();
  } catch (error) {
    throw mapError(error);
  }
}
