import 'package:flutter/material.dart';

class MeasuredImage extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeMeasured;

  const MeasuredImage({
    super.key,
    required this.child,
    required this.onSizeMeasured,
  });

  @override
  State<MeasuredImage> createState() => _MeasuredImageState();
}

class _MeasuredImageState extends State<MeasuredImage> {
  final _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_measureSize);
  }

  void _measureSize(_) {
    final renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      widget.onSizeMeasured(renderBox.size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      child: widget.child,
    );
  }
}
