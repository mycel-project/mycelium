class NodeData {
  const NodeData({
    this.title,
    this.src,
  });

  final String? title;
  final String? src;

  factory NodeData.fromJson(Map<String, dynamic> json) {
    return NodeData(
      title: json['title'],
      src: json['src'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'src': src,
  };
}
