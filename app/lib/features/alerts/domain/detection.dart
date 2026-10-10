enum Danger { low, medium, high }

class Detection {
  final int id;
  final String label;
  final double confidence;
  final String direction; // left | front | right
  final int? clock;
  final double distanceM;
  final Danger danger;

  const Detection({
    required this.id,
    required this.label,
    required this.confidence,
    required this.direction,
    required this.distanceM,
    required this.danger,
    this.clock,
  });

  factory Detection.fromJson(Map<String, dynamic> j) => Detection(
        id: (j['id'] ?? 0) as int,
        label: j['label'] as String,
        confidence: (j['conf'] ?? j['confidence'] ?? 0).toDouble(),
        direction: j['direction'] as String,
        clock: j['clock'] as int?,
        distanceM: (j['distance_m'] as num).toDouble(),
        danger: Danger.values.firstWhere(
          (d) => d.name == j['danger'],
          orElse: () => Danger.low,
        ),
      );
}