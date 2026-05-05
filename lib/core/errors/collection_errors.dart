abstract class CollectionError {
  String? get message;
}

class UnknownCollectionError extends CollectionError {
  @override
  final String? message;
  
  UnknownCollectionError(this.message);
}
