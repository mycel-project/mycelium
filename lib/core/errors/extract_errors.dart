abstract class ExtractError {}

class ExtractMismatchError extends ExtractError {
  final String? message;

  ExtractMismatchError(this.message);
}

class UnknownExtractError extends ExtractError {
  final String? message;

  UnknownExtractError(this.message);
}
