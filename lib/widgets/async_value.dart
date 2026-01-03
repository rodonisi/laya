import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Async<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace)? error;

  const Async({
    super.key,
    required this.asyncValue,
    required this.data,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: data,
      loading:
          loading ?? () => const Center(child: CircularProgressIndicator()),
      error: error ?? (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class AsyncSliver<T> extends StatelessWidget {
  final AsyncValue<T> asyncValue;
  final Widget Function(T) data;
  final Widget Function()? loading;
  final Widget Function(Object, StackTrace)? error;

  const AsyncSliver({
    super.key,
    required this.asyncValue,
    required this.data,
    this.loading,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: data,
      loading:
          loading ??
          () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          error ??
          (error, stack) =>
              SliverToBoxAdapter(child: Center(child: Text('Error: $error'))),
    );
  }
}
