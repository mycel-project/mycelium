abstract class NodeUpdateError {}

class InvalidNodeUpdateError extends NodeUpdateError {
  final String? message;

  InvalidNodeUpdateError(this.message);
}

class UnknownNodeUpdateError extends NodeUpdateError {}
