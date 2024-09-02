import 'dart:convert';
import 'entity_model.dart';

class Owner implements Entity {
  final String id;
  final String name;
  final String gender;
  final String birthdate;
  final String birthtime;
  //final String? location;
  final String livingSituation;
  final int activityLevel;
  final int interactionLevel;
  final String workSchedule;
  final String petExperience;
  final int groomingCommitment;
  final int noiseTolerance;
  final String petReason;

  Owner({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthdate,
    required this.birthtime,
    //this.location,
    required this.livingSituation,
    required this.activityLevel,
    required this.interactionLevel,
    required this.workSchedule,
    required this.petExperience,
    required this.groomingCommitment,
    required this.noiseTolerance,
    required this.petReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthdate': birthdate,
      'birthtime': birthtime,
      //'location': location,
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
      birthtime: json['birthtime'],
      //location: json['location'],
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

  @override
  dynamic get(String propertyName) {
    switch (propertyName) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'gender':
        return gender;
      case 'birthdate':
        return birthdate;
      case 'birthtime':
        return birthtime;
      // case 'location':
      //   return location;
      case 'livingSituation':
        return livingSituation;
      case 'activityLevel':
        return activityLevel;
      case 'interactionLevel':
        return interactionLevel;
      case 'workSchedule':
        return workSchedule;
      case 'petExperience':
        return petExperience;
      case 'groomingCommitment':
        return groomingCommitment;
      case 'noiseTolerance':
        return noiseTolerance;
      case 'petReason':
        return petReason;
      default:
        throw ArgumentError('Property $propertyName does not exist on Pet');
    }
  }
}
