extension IntExtensions on int {
  String prettyInt() {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)}B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)}M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)}K';
    } else {
      return toString();
    }
  }
}
