import 'package:flutter/material.dart';

Widget buildCheckboxRow(String label, bool value, Function(bool?) onChanged, BuildContext context,) {
  final isTablet = MediaQuery.of(context).size.width > 600;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Checkbox(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      Flexible(
        child: Text(
          label,
          style: TextStyle(fontSize: isTablet ? 14 : 12),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
