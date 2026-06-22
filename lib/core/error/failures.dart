abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'A server error occurred.']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'A cache error occurred.']) : super(message);
}

class DatabaseFailure extends Failure {
  const DatabaseFailure([String message = 'A database error occurred.']) : super(message);
}
