// BaseLearningUnit and LearningUnit are separate to avoid verbose 'super' constructor boilerplate in subclasses (Fragment/Spore).
// Using composition instead of a full merge keeps child models lean and clean (and closer from mycel's code)

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

  BaseLearningUnit copyWith({
    String? id,
    String? nodeId,
    double? priority,
    int? due,
    int? lastReview,
    int? slot,
  }) {
    return BaseLearningUnit(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      priority: priority ?? this.priority,
      due: due ?? this.due,
      lastReview: lastReview ?? this.lastReview,
      slot: slot ?? this.slot,
    );
  }
}

// High level class gathering Spore and Fragment, used for typing inside Node model and quick access through getter
sealed class LearningUnit {
  LearningUnit();

  BaseLearningUnit get _base => switch (this) {
    Fragment f => f.unit,
    Spore s => s.unit,
  };

  String get id => _base.id;
  String get nodeId => _base.nodeId;
  double get priority => _base.priority;
  int get due => _base.due;
  int? get lastReview => _base.lastReview;
  int get slot => _base.slot;

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

  Fragment copyWith({BaseLearningUnit? unit, bool? dismiss, FragmentRef? ref}) {
    return Fragment(
      unit: unit ?? this.unit,
      dismiss: dismiss ?? this.dismiss,
      ref: ref ?? this.ref,
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
  final double? stability;
  final double? difficulty;
  final int? step;

  FsrsData({
    required this.state,
    required this.stability,
    required this.difficulty,
    required this.step,
  }) : super("fsrs");
  factory FsrsData.fromJson(Map<String, dynamic> json) {
    return FsrsData(
      state: json['state'],
      stability: (json['stability'] as num?)?.toDouble(),
      difficulty: (json['difficulty'] as num?)?.toDouble(),
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

  Spore copyWith({BaseLearningUnit? unit, LearningData? learningData}) {
    return Spore(
      unit: unit ?? this.unit,
      learningData: learningData ?? this.learningData,
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
    required this.contentPreview,
    required this.learningUnits,
    required this.data,
    this.parentId,
    this.deletedAt,
    this.fields,
  });

  final String id;
  final String collectionId;
  final String templateId;
  final String type;
  final String status;
  final int updatedAt;
  final int createdAt;
  final String? parentId;
  final int? deletedAt;
  final String contentPreview;
  final Map<String, String>? fields;
  final List<LearningUnit> learningUnits;
  final Map<String, dynamic> data;

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      id: json['id'],
      collectionId: json['collection_id'],
      templateId: json['template_id'],
      type: json['type'],
      status: json['status'],
      updatedAt: json['updated_at'],
      createdAt: json['created_at'],
      parentId: json['parent_id'],
      deletedAt: json['deleted_at'],
      contentPreview: json['content_preview'],
      fields: json['fields'] != null
          ? Map<String, String>.from(json['fields'] as Map)
          : null,
      learningUnits: (json['learning_units'] as List)
          .map((x) => LearningUnit.fromJson(x as Map<String, dynamic>))
          .toList(),
      data: json['data'] as Map<String, dynamic>,
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
      parentId: parentId ?? this.parentId,
      deletedAt: deletedAt ?? this.deletedAt,
      contentPreview: contentPreview ?? this.contentPreview,
      fields: fields ?? this.fields,
      learningUnits: learningUnits ?? this.learningUnits,
      data: data ?? this.data,
    );
  }

  LearningUnit getUnit([int slot = 1]) {
    for (final u in learningUnits) {
      final currentSlot = switch (u) {
        Fragment f => f.unit.slot,
        Spore s => s.unit.slot,
      };
      if (currentSlot == slot) return u;
    }
    throw StateError('No learning unit found for slot $slot on node $id');
  }

  Fragment? getFragment([int slot = 1]) {
    final unit = getUnit(slot);
    return unit is Fragment ? unit : null;
  }

  Spore? getSpore([int slot = 1]) {
    final unit = getUnit(slot);
    return unit is Spore ? unit : null;
  }

  String get firstFieldValue => fields?.values.firstOrNull ?? "";
  String get firstFieldKey => fields?.keys.firstOrNull ?? "";
}
