abstract class Either<L, R> {}

class Left<L, R> extends Either<L, R> {
  final L value;
  Left(this.value);
}

class Right<L, R> extends Either<L, R> {
  final R value;
  Right(this.value);
}

extension EitherX<L, R> on Either<L, R> {
  T fold<T>(
    T Function(L l) onLeft,
    T Function(R r) onRight,
  ) {
    final self = this;

    if (self is Left<L, R>) {
      return onLeft(self.value);
    }

    if (self is Right<L, R>) {
      return onRight(self.value);
    }

    throw Exception("Invalid Either state");
  }
}
