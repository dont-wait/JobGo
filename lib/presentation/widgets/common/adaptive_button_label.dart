import 'package:flutter/material.dart';

class AdaptiveButtonLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const AdaptiveButtonLabel({super.key, required this.text, this.style});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.center,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
        style: style,
      ),
    );
  }
}
