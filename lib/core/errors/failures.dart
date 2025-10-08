class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure([String message = 'Server Failure']) : super(message);
}

class CacheFailure extends Failure {
  CacheFailure([String message = 'Cache Failure']) : super(message);
}
