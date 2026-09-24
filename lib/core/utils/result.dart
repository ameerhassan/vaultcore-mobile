import 'package:flutter_enterprise_clean_architecture/core/error/failures.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final data) => data,
        Error() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        Error(failure: final failure) => failure,
      };

  R fold<R>({
    required R Function(Failure failure) onFailure,
    required R Function(T data) onSuccess,
  }) {
    return switch (this) {
      Success(data: final d) => onSuccess(d),
      Error(failure: final f) => onFailure(f),
    };
  }
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
