import 'package:flutter/material.dart';
import '../config/theme.dart';

class CustomExpansionPanelList extends StatelessWidget {
  final List<CustomExpansionPanel> children;
  final ExpansionPanelCallback expansionCallback;
  final VoidCallback? onNonExpandableTap;

  const CustomExpansionPanelList({
    super.key,
    required this.children,
    required this.expansionCallback,
    this.onNonExpandableTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(children.length, (index) {
        final child = children[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: child.isExpanded
                ? AppTheme.lemonChiffon
                : AppTheme.primaryBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent1.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: child.canExpand
                    ? () => expansionCallback(index, child.isExpanded)
                    : onNonExpandableTap,
                child: child.headerBuilder(context, child.isExpanded),
              ),
              if (child.isExpanded) child.body,
            ],
          ),
        );
      }),
    );
  }
}

class CustomExpansionPanel {
  final Widget Function(BuildContext, bool) headerBuilder;
  final Widget body;
  final bool isExpanded;
  final bool canExpand;

  CustomExpansionPanel({
    required this.headerBuilder,
    required this.body,
    this.isExpanded = false,
    this.canExpand = true,
  });
}