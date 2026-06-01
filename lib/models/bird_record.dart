enum BirdRecordStatus { draft, published }

class BirdRecord {
  final String id;
  final String commonName;
  final String scientificName;
  final String zone;
  final DateTime createdAt;
  final String certainty;
  final String? imagePath;
  final String notes;
  final BirdRecordStatus status;

  const BirdRecord({
    required this.id,
    required this.commonName,
    required this.scientificName,
    required this.zone,
    required this.createdAt,
    required this.certainty,
    required this.imagePath,
    required this.notes,
    required this.status,
  });

  bool get isDraft => status == BirdRecordStatus.draft;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'commonName': commonName,
      'scientificName': scientificName,
      'zone': zone,
      'createdAt': createdAt.toIso8601String(),
      'certainty': certainty,
      'imagePath': imagePath,
      'notes': notes,
      'status': status.name,
    };
  }

  factory BirdRecord.fromJson(Map<String, dynamic> json) {
    return BirdRecord(
      id: json['id'] as String,
      commonName: json['commonName'] as String,
      scientificName: json['scientificName'] as String? ?? 'Pendiente',
      zone: json['zone'] as String? ?? 'Sin ubicacion',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      certainty: json['certainty'] as String? ?? 'Pendiente',
      imagePath: json['imagePath'] as String?,
      notes: json['notes'] as String? ?? '',
      status: BirdRecordStatus.values.firstWhere(
        (value) => value.name == json['status'],
        orElse: () => BirdRecordStatus.draft,
      ),
    );
  }
}
