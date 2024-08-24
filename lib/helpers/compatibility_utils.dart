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

void navigateToCardDetail(BuildContext context, String cardId) {
  Navigator.pushNamed(
    context,
    '/result/card',
    arguments: {'cardId': cardId},
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

String getLevelFor(double percent) {
  String level = 'They\'re like oil and water!';
  final percentInt = (percent * 100).toInt();
  if (percentInt > 80) {
    level = 'They\'re very harmonious!';
  } else if (percentInt > 60) {
    level = 'They\'re a promising pair!';
  } else if (percentInt > 40) {
    level = 'They\'re finding their rhythm.';
  } else if (percentInt > 20) {
    level = 'There\'s room for improvement.';
  }
  return level;
}
