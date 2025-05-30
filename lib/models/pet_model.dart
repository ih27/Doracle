import 'dart:convert';
import 'entity_model.dart';

class Pet implements Entity {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final String birthdate;
  final String birthtime;
  //final String? location;
  final List<String> temperament;
  final int exerciseRequirement;
  final int socializationNeed;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    required this.birthdate,
    required this.birthtime,
    //this.location,
    required this.temperament,
    required this.exerciseRequirement,
    required this.socializationNeed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birthdate': birthdate,
      'birthtime': birthtime,
      //'location': location,
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
      breed: json['breed'],
      birthdate: json['birthdate'],
      birthtime: json['birthtime'],
      //location: json['location'],
      temperament: List<String>.from(json['temperament'] ?? []),
      exerciseRequirement: json['exerciseRequirement'] as int,
      socializationNeed: json['socializationNeed'] as int,
    );
  }

  static List<Pet> listFromJson(String str) =>
      List<Pet>.from(json.decode(str).map((x) => Pet.fromJson(x)));

  static String listToJson(List<Pet> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

  @override
  dynamic get(String propertyName) {
    switch (propertyName) {
      case 'id':
        return id;
      case 'name':
        return name;
      case 'species':
        return species;
      case 'breed':
        return breed;
      case 'birthdate':
        return birthdate;
      case 'birthtime':
        return birthtime;
      // case 'location':
      //   return location;
      case 'temperament':
        return temperament;
      case 'exerciseRequirement':
        return exerciseRequirement;
      case 'socializationNeed':
        return socializationNeed;
      default:
        throw ArgumentError('Property $propertyName does not exist on Pet');
    }
  }
}
