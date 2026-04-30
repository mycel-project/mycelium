abstract class NodeError {}

class NodeNotFoundError extends NodeError {
  final String? message;

  NodeNotFoundError(this.message);
}

class UnknownNodeError extends NodeError {}

