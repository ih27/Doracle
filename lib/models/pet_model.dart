import 'dart:convert';

class Pet {
  final String id;
  final String name;
  final String imageUrl;

  Pet({required this.id, required this.name, required this.imageUrl});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
    };
  }

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
    );
  }

  static List<Pet> listFromJson(String str) =>
      List<Pet>.from(json.decode(str).map((x) => Pet.fromJson(x)));

  static String listToJson(List<Pet> data) =>
      json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
}
