import 'package:twitter_alternative/app/data/models/user_model.dart';

class PostModel {
  String id;
  String userId;
  String content;
  String? imageUrl;
  int likesCount;
  int dislikesCount;
  DateTime createdAt;
  DateTime updatedAt;

  // Optional fields for UI rendering
  UserModel? author;
  String? userReaction; // 'like', 'dislike', or null

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrl,
    required this.likesCount,
    required this.dislikesCount,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.userReaction,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      likesCount: json['likes_count'] as int,
      dislikesCount: json['dislikes_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      userReaction: json['user_reaction'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
      'likes_count': likesCount,
      'dislikes_count': dislikesCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // Don't include the optional fields in JSON
    };
  }

  // Create a map for insertion to Supabase
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'content': content,
      'image_url': imageUrl,
    };
  }

  // Create a copy of this PostModel with the given fields updated
  PostModel copyWith({
    String? id,
    String? userId,
    String? content,
    String? imageUrl,
    int? likesCount,
    int? dislikesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? author,
    String? userReaction,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likesCount: likesCount ?? this.likesCount,
      dislikesCount: dislikesCount ?? this.dislikesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      userReaction: userReaction ?? this.userReaction,
    );
  }
}
