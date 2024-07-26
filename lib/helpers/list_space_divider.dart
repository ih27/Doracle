import 'package:flutter/material.dart';

extension ListSpaceBetweenExtension on List<Widget> {
  List<Widget> divide({double? width, double? height}) => [
        if (isNotEmpty) this[0],
        for (int i = 1; i < length; i++) ...[
          SizedBox(width: width, height: height),
          this[i]
        ]
      ];
}
