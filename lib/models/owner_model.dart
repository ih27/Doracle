import 'dart:convert';

class Owner {
  final String id;
  final String name;
  final String gender;
  final String? birthdate;
  final String? location;
  final String? livingSituation;
  final int activityLevel;
  final int interactionLevel;
  final String? workSchedule;
  final String? petExperience;
  final int groomingCommitment;
  final int noiseTolerance;
  final String? petReason;

  Owner({
    required this.id,
    required this.name,
    required this.gender,
    this.birthdate,
    this.location,
    this.livingSituation,
    required this.activityLevel,
    required this.interactionLevel,
    this.workSchedule,
    this.petExperience,
    required this.groomingCommitment,
    required this.noiseTolerance,
    this.petReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthdate': birthdate,
      'location': location,
      'livingSituation': livingSituation,
      'activityLevel': activityLevel,
      'interactionLevel': interactionLevel,
      'workSchedule': workSchedule,
      'petExperience': petExperience,
      'groomingCommitment': groomingCommitment,
      'noiseTolerance': noiseTolerance,
      'petReason': petReason,
    };
  }

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      location: json['location'],
      livingSituation: json['livingSituation'],
      activityLevel: json['activityLevel'] as int,
      interactionLevel: json['interactionLevel'] as int,
      workSchedule: json['workSchedule'],
      petExperience: json['petExperience'],
      groomingCommitment: json['groomingCommitment'] as int,
      noiseTolerance: json['noiseTolerance'] as int,
      petReason: json['petReason'],
    );
  }

  static List<Owner> listFromJson(String str) =>
      List<Owner>.from(json.decode(str).map((x) => Owner.fromJson(x)));

  static String listToJson(List<Owner> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}
