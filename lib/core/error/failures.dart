import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? code;

  const Failure({required this.message, this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Internal banking gateway error', super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Local offline storage failed', super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Device is offline. Local transaction queued.', super.code});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed. Please verify credentials.', super.code});
}
