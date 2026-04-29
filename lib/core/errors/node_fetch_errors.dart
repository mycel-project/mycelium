abstract class NodeFetchError {}

class NodeNotFoundError extends NodeFetchError {
  final String? message;

  NodeNotFoundError(this.message);
}

class UnknownNodeFetchError extends NodeFetchError {}
