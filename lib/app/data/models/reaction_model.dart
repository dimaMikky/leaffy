class ReactionModel {
  String id;
  String userId;
  String postId;
  String reactionType; // 'like' or 'dislike'
  DateTime createdAt;

  ReactionModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.reactionType,
    required this.createdAt,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      reactionType: json['reaction_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'reaction_type': reactionType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create a map for insertion to Supabase
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'reaction_type': reactionType,
    };
  }
}
