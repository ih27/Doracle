import 'dart:convert';

class Pet {
  final String id;
  final String name;
  final String species;
  final String? birthdate;
  final String? location;
  final String? temperament;
  final String? exerciseRequirement;
  final String? socializationNeed;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.birthdate,
    this.location,
    this.temperament,
    this.exerciseRequirement,
    this.socializationNeed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'birthdate': birthdate,
      'location': location,
      'temperament': temperament,
      'exerciseRequirement': exerciseRequirement,
      'socializationNeed': socializationNeed,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      birthdate: json['birthdate'],
      location: json['location'],
      temperament: json['temperament'],
      exerciseRequirement: json['exerciseRequirement'],
      socializationNeed: json['socializationNeed'],
    );
  }

  static List<Pet> listFromJson(String str) =>
      List<Pet>.from(json.decode(str).map((x) => Pet.fromJson(x)));

  static String listToJson(List<Pet> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}
