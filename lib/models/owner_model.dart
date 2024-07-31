import 'dart:convert';

class Owner {
  final String id;
  final String name;
  final String gender;
  final String? birthdate;
  final String? location;
  final List<String> interests;
  final int activityLevel;
  final int petExperience;

  Owner({
    required this.id,
    required this.name,
    required this.gender,
    this.birthdate,
    this.location,
    required this.interests,
    required this.activityLevel,
    required this.petExperience,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthdate': birthdate,
      'location': location,
      'interests': interests,
      'activityLevel': activityLevel,
      'petExperience': petExperience,
    };
  }

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      birthdate: json['birthdate'],
      location: json['location'],
      interests: List<String>.from(json['interests'] ?? []),
      activityLevel: json['activityLevel'] as int,
      petExperience: json['petExperience'] as int,
    );
  }

  static List<Owner> listFromJson(String str) =>
      List<Owner>.from(json.decode(str).map((x) => Owner.fromJson(x)));

  static String listToJson(List<Owner> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}