abstract class RessourceError {}

class UnprocessableResourceError extends RessourceError {
  final String? message;

  UnprocessableResourceError(this.message);
}

class RessourceNotFoundError extends RessourceError {
  final String? message;

  RessourceNotFoundError(this.message);
}

class UnknownRessourceError extends RessourceError {}
