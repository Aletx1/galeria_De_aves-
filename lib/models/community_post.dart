class CommunityPost {
  final String id;
  final String author;
  final String description;
  final DateTime createdAt;
  final String? imagePath;
  final String? sourceRecordId;
  final int likes;
  final bool hidden;

  const CommunityPost({
    required this.id,
    required this.author,
    required this.description,
    required this.createdAt,
    required this.imagePath,
    required this.sourceRecordId,
    required this.likes,
    required this.hidden,
  });

  CommunityPost copyWith({String? description, int? likes, bool? hidden}) {
    return CommunityPost(
      id: id,
      author: author,
      description: description ?? this.description,
      createdAt: createdAt,
      imagePath: imagePath,
      sourceRecordId: sourceRecordId,
      likes: likes ?? this.likes,
      hidden: hidden ?? this.hidden,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'sourceRecordId': sourceRecordId,
      'likes': likes,
      'hidden': hidden,
    };
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      author: json['author'] as String? ?? 'Usuario AvesCL',
      description: json['description'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      imagePath: json['imagePath'] as String?,
      sourceRecordId: json['sourceRecordId'] as String?,
      likes: json['likes'] as int? ?? 0,
      hidden: json['hidden'] as bool? ?? false,
    );
  }
}
