sealed class ApiResult<T> {}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  ApiSuccess(this.data);
}

class ApiError extends ApiResult<Never> {
  final String code;
  final int? statusCode;
  final String? message;

  ApiError(this.code, {this.statusCode, this.message});
}
