import 'package:flutter/material.dart';
import 'package:kover/utils/layout_constants.dart';

class SliverBottomPadding extends StatelessWidget {
  const SliverBottomPadding({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height:
            LayoutConstants.mediumPadding +
            MediaQuery.of(context).padding.bottom,
      ),
    );
  }
}
