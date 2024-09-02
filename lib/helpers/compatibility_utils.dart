import 'dart:convert';

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/owner_model.dart';
import '../models/pet_model.dart';

String generateConsistentPlanId(dynamic entity1, dynamic entity2) {
  String id1 = _getStableEntityIdentifier(entity1);
  String id2 = _getStableEntityIdentifier(entity2);

  List<String> sortedIds = [id1, id2]..sort();
  return sortedIds.join(' & ');
}

String _getStableEntityIdentifier(dynamic entity) {
  if (entity is Pet) {
    return 'Pet_${entity.name}_${entity.species}${entity.birthdate != null ? '_${entity.birthdate}' : ''}';
  } else if (entity is Owner) {
    return 'Owner_${entity.name}${entity.birthdate != null ? '_${entity.birthdate}' : ''}';
  } else {
    throw ArgumentError('Unknown entity type');
  }
}

void navigateToCardDetail(BuildContext context, String cardId, String planId) {
  Navigator.pushNamed(
    context,
    '/result/card',
    arguments: {'cardId': cardId, 'planId': planId},
  );
}

void navigateToImprovementPlan(BuildContext context, String planId) {
  Navigator.pushNamed(
    context,
    '/improvement_plan',
    arguments: {'planId': planId},
  );
}

void navigateToHome(BuildContext context) {
  Navigator.pushNamed(
    context,
    '/',
  );
}

Color getColorFor(double percent) {
  Color progressColor = AppTheme.tomato;
  final percentInt = (percent * 100).toInt();
  if (percentInt > 75) {
    progressColor = AppTheme.secondaryColor;
  } else if (percentInt > 50) {
    progressColor = AppTheme.naplesYellow;
  } else if (percentInt > 25) {
    progressColor = AppTheme.sandyBrown;
  }
  return progressColor;
}

String getLevelFor(double percent, bool isPetOwner) {
  final percentInt = (percent * 100).toInt();
  final prefix = isPetOwner ? 'You are' : 'They\'re';

  if (percentInt > 80) {
    return '$prefix very harmonious!';
  } else if (percentInt > 60) {
    return '$prefix a promising pair!';
  } else if (percentInt > 40) {
    return '$prefix finding your rhythm.';
  } else if (percentInt > 20) {
    return 'There\'s room for improvement.';
  } else {
    return isPetOwner
        ? 'You are like oil and water!'
        : 'They\'re like oil and water!';
  }
}

String getEntityImage(dynamic entity) {
  if (entity is Pet) {
    switch (entity.species.toLowerCase()) {
      case 'dog':
        return 'assets/images/dog.png';
      case 'cat':
        return 'assets/images/cat.png';
      case 'bird':
        return 'assets/images/bird.png';
      default:
        return 'assets/images/fish.png';
    }
  } else {
    switch ((entity as Owner).gender.toLowerCase()) {
      case 'male':
        return 'assets/images/owner_he.png';
      case 'female':
        return 'assets/images/owner_she.png';
      default:
        return 'assets/images/owner_other.png';
    }
  }
}

String encodeEntity(dynamic entity) {
  if (entity is Pet) {
    return json.encode({'type': 'pet', 'data': entity.toJson()});
  } else if (entity is Owner) {
    return json.encode({'type': 'owner', 'data': entity.toJson()});
  }
  throw ArgumentError('Unknown entity type');
}

dynamic decodeEntity(String? encodedEntity) {
  if (encodedEntity == null) return null;
  final decoded = json.decode(encodedEntity);
  if (decoded['type'] == 'pet') {
    return Pet.fromJson(decoded['data']);
  } else if (decoded['type'] == 'owner') {
    return Owner.fromJson(decoded['data']);
  }
  throw ArgumentError('Unknown entity type');
}
