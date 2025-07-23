import 'package:flutter/material.dart';
import 'package:mock_interview/core/utils/extensions/media_query_extension.dart';

class ORDivider extends StatelessWidget {
  const ORDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 2,
          width: context.width / 2.4,
          color: Theme.of(context).colorScheme.secondary,
        ),
        Text(
          'OR',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Container(
          height: 2,
          width: context.width / 2.4,
          color: Theme.of(context).colorScheme.secondary,
        ),
      ],
    );
  }
}
