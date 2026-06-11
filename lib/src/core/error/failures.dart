abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Location error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Không có kết nối Internet.']);
}
