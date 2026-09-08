import 'package:drift/drift.dart';

/// Build an OR of [columns] each containing [query].
Expression<bool> containsAny(
  String query,
  Iterable<GeneratedColumn<String>> columns,
) {
  return columns
      .map((column) => column.contains(query))
      .reduce((a, b) => a | b);
}

/// Progress ratio (pages read / total pages) as a double expression.
Expression<double> progressRatio(
  Expression<int> pagesReadSum,
  Expression<int> totalPages,
) {
  return pagesReadSum.cast<double>() / totalPages.cast<double>();
}

/// Whether a set of [pagesReadSum] is unread against [totalPages].
Expression<bool> hasUnreadProgress(
  Expression<int> pagesReadSum,
  Expression<int> totalPages,
) {
  return pagesReadSum.isNull() | pagesReadSum.isSmallerThan(totalPages);
}
