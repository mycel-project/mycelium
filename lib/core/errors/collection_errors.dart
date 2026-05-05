abstract class CollectionError {
  String? get message;
}

class NotFoundCollectionError extends CollectionError {
  @override
  final String? message;
  
  NotFoundCollectionError(this.message);
}


class UnknownCollectionError extends CollectionError {
  @override
  final String? message;
  
  UnknownCollectionError(this.message);
}
