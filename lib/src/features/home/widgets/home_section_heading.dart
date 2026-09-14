import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class HomeSectionHeading extends StatelessWidget {
  const HomeSectionHeading(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: context.colors.ink,
          ),
        ),
      ],
    );
  }
}
