import 'package:flutter/material.dart';

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.spacing = 20,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet) {
      return Row(
        children: children
            .asMap()
            .entries
            .map((entry) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: entry.key < children.length - 1 ? spacing : 0,
            ),
            child: entry.value,
          ),
        ))
            .toList(),
      );
    } else {
      return Column(
        children: children
            .asMap()
            .entries
            .map((entry) => Padding(
          padding: EdgeInsets.only(
            bottom: entry.key < children.length - 1 ? spacing : 0,
          ),
          child: entry.value,
        ))
            .toList(),
      );
    }
  }
}