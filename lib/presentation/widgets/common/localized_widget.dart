import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/locale_provider.dart';

/// Wrapper widget để rebuild children khi ngôn ngữ thay đổi
class LocalizedWidget extends StatelessWidget {
  final Widget Function(BuildContext) builder;

  const LocalizedWidget({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, _, __) => builder(context),
    );
  }
}
