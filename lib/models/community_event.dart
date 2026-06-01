class CommunityEvent {
  final String id;
  final String title;
  final String description;
  final String birdFocus;
  final DateTime createdAt;
  final DateTime endsAt;
  final int likes;
  final int participants;
  final bool hidden;
  final bool likedByCurrentUser;
  final List<String> submittedRecordIds;

  const CommunityEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.birdFocus,
    required this.createdAt,
    required this.endsAt,
    required this.likes,
    required this.participants,
    required this.hidden,
    required this.likedByCurrentUser,
    required this.submittedRecordIds,
  });

  bool get currentUserParticipated => submittedRecordIds.isNotEmpty;

  CommunityEvent copyWith({
    int? likes,
    int? participants,
    bool? hidden,
    bool? likedByCurrentUser,
    List<String>? submittedRecordIds,
  }) {
    return CommunityEvent(
      id: id,
      title: title,
      description: description,
      birdFocus: birdFocus,
      createdAt: createdAt,
      endsAt: endsAt,
      likes: likes ?? this.likes,
      participants: participants ?? this.participants,
      hidden: hidden ?? this.hidden,
      likedByCurrentUser: likedByCurrentUser ?? this.likedByCurrentUser,
      submittedRecordIds: submittedRecordIds ?? this.submittedRecordIds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'birdFocus': birdFocus,
      'createdAt': createdAt.toIso8601String(),
      'endsAt': endsAt.toIso8601String(),
      'likes': likes,
      'participants': participants,
      'hidden': hidden,
      'likedByCurrentUser': likedByCurrentUser,
      'submittedRecordIds': submittedRecordIds,
    };
  }

  factory CommunityEvent.fromJson(Map<String, dynamic> json) {
    return CommunityEvent(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Evento sin titulo',
      description: json['description'] as String? ?? '',
      birdFocus: json['birdFocus'] as String? ?? 'Tema libre',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      endsAt:
          DateTime.tryParse(json['endsAt'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 7)),
      likes: json['likes'] as int? ?? 0,
      participants: json['participants'] as int? ?? 0,
      hidden: json['hidden'] as bool? ?? false,
      likedByCurrentUser: json['likedByCurrentUser'] as bool? ?? false,
      submittedRecordIds: (json['submittedRecordIds'] as List<dynamic>? ?? [])
          .map((id) => id.toString())
          .toList(),
    );
  }
}
