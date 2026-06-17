// Base class from which Spore and Fragment inherit
class BaseLearningUnit {
  final String id;
  final String nodeId;
  final double priority;
  final int due;
  final int? lastReview;
  final int slot;

  BaseLearningUnit({
    required this.id,
    required this.nodeId,
    required this.priority,
    required this.due,
    this.lastReview,
    required this.slot,
  });

  factory BaseLearningUnit.fromJson(Map<String, dynamic> json) {
    return BaseLearningUnit(
      id: json['id'],
      nodeId: json['node_id'],
      priority: json['priority'].toDouble(),
      due: json['due'],
      lastReview: json['last_review'],
      slot: json['slot'],
    );
  }
}

// High level class gathering Spore and Fragment, used for typing inside Node model
sealed class LearningUnit {
  LearningUnit();

  factory LearningUnit.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'fragment' => Fragment.fromJson(json),
      'spore' => Spore.fromJson(json),
      _ => throw Exception('Unknown learning unit type: ${json['type']}'),
    };
  }
}

// FRAGMENT

sealed class FragmentRef {
  final String type;
  FragmentRef(this.type);

  static FragmentRef? fromJson(Map<String, dynamic> json) {
    return null; 
  }
}

class Fragment extends LearningUnit {
  final BaseLearningUnit unit;
  final bool dismiss;
  final FragmentRef? ref;

  final String type = "fragment";

  Fragment({required this.unit, required this.dismiss, required this.ref});

  factory Fragment.fromJson(Map<String, dynamic> json) {
    return Fragment(
      unit: BaseLearningUnit.fromJson(json),
      dismiss: json['dismiss'] ?? false,
      ref: json['ref'] != null ? FragmentRef.fromJson(json['ref']) : null,
    );
  }
}

// SPORE

sealed class LearningData {
  final String type;
  LearningData(this.type);

  factory LearningData.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'fsrs' => FsrsData.fromJson(json),
      _ => throw Exception('Unknown learning data type: ${json['type']}'),
    };
  }
}

class FsrsData extends LearningData {
  final int state;
  final double stability;
  final double difficulty;
  final int step;

  FsrsData({
    required this.state,
    required this.stability,
    required this.difficulty,
    required this.step,
  }) : super("fsrs");
  factory FsrsData.fromJson(Map<String, dynamic> json) {
    return FsrsData(
      state: json['state'],
      stability: json['stability'].toDouble(),
      difficulty: json['difficulty'].toDouble(),
      step: json['step'],
    );
  }
}

class Spore extends LearningUnit {
  final BaseLearningUnit unit;
  final LearningData learningData;

  final String type = "spore";

  Spore({required this.unit, required this.learningData});

  factory Spore.fromJson(Map<String, dynamic> json) {
    return Spore(
      unit: BaseLearningUnit.fromJson(json),
      learningData: LearningData.fromJson(json['learning_data']),
    );
  }
}

// NODE

class Node {
  const Node({
    required this.id,
    required this.collectionId,
    required this.templateId,
    required this.type,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
    required this.dues,
    required this.priorities,
    required this.contentPreview,
    this.parentId,
    this.deletedAt,
    this.fields,
    this.learningUnits,
    this.data,
  });

  final String id;
  final String collectionId;
  final String templateId;
  final String type;
  final String status;
  final int updatedAt;
  final int createdAt;
  final List<int> dues;
  final List<double> priorities;
  final String? parentId;
  final int? deletedAt;
  final String? contentPreview;
  final Map<String, String>? fields;
  final List<LearningUnit>? learningUnits;
  final Map<String, dynamic>? data;

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'],
      collectionId: json['collection_id'],
      templateId: json['template_id'],
      type: json['type'],
      status: json['status'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      dues: List<int>.from(json['dues']),
      priorities: List<double>.from(
        json['priorities'].map((x) => double.parse(x.toStringAsFixed(3))),
      ),
      parentId: json['parent_id'],
      deletedAt: json['deleted_at'],
      contentPreview: json['content_preview'],
      fields: json['fields'] != null
          ? Map<String, String>.from(json['fields'])
          : null,
      learningUnits: json['learning_units'] != null
          ? (json['learning_units'] as List)
                .map((x) => LearningUnit.fromJson(x as Map<String, dynamic>))
                .toList()
          : null,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Node copyWith({
    String? id,
    String? collectionId,
    String? templateId,
    String? type,
    String? status,
    int? updatedAt,
    int? createdAt,
    List<int>? dues,
    List<double>? priorities,
    String? parentId,
    int? deletedAt,
    String? contentPreview,
    Map<String, String>? fields,
    List<LearningUnit>? learningUnits,
    Map<String, dynamic>? data,
  }) {
    return Node(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      templateId: templateId ?? this.templateId,
      type: type ?? this.type,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      dues: dues ?? this.dues,
      priorities: priorities ?? this.priorities,
      parentId: parentId ?? this.parentId,
      deletedAt: deletedAt ?? this.deletedAt,
      contentPreview: contentPreview ?? this.contentPreview,
      fields: fields ?? this.fields,
      learningUnits: learningUnits ?? this.learningUnits,
      data: data ?? this.data,
    );
  }
}
