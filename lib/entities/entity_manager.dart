import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pet_model.dart';
import '../models/owner_model.dart';

abstract class EntityManager<T> extends ChangeNotifier {
  List<T> _entities = [];
  final String storageKey;

  EntityManager(this.storageKey) {
    loadEntities();
  }

  List<T> get entities => _entities;

  Future<void> loadEntities() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entitiesJson = prefs.getString(storageKey);
    if (entitiesJson != null) {
      _entities = _parseEntities(entitiesJson);
      notifyListeners();
    }
  }

  Future<void> saveEntities() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, _entitiesToJson(_entities));
  }

  Future<void> addEntity(T entity) async {
    _entities.add(entity);
    await saveEntities();
    notifyListeners();
  }

  Future<void> updateEntity(T oldEntity, T newEntity) async {
    final index = _entities.indexWhere((e) => _getId(e) == _getId(oldEntity));
    if (index != -1) {
      _entities[index] = newEntity;
      await saveEntities();
      notifyListeners();
    }
  }

  Future<void> removeEntity(T entity) async {
    _entities.removeWhere((e) => _getId(e) == _getId(entity));
    await saveEntities();
    notifyListeners();
  }

  List<T> _parseEntities(String json);
  String _entitiesToJson(List<T> entities);
  String _getId(T entity);
}

class PetManager extends EntityManager<Pet> {
  PetManager() : super('pets_list');

  @override
  List<Pet> _parseEntities(String json) => Pet.listFromJson(json);

  @override
  String _entitiesToJson(List<Pet> entities) => Pet.listToJson(entities);

  @override
  String _getId(Pet entity) => entity.id;
}

class OwnerManager extends EntityManager<Owner> {
  OwnerManager() : super('owners_list');

  @override
  List<Owner> _parseEntities(String json) => Owner.listFromJson(json);

  @override
  String _entitiesToJson(List<Owner> entities) => Owner.listToJson(entities);

  @override
  String _getId(Owner entity) => entity.id;
}