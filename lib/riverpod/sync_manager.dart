import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:fluvita/riverpod/providers/series.dart';
import 'package:fluvita/riverpod/repository/chapters_repository.dart';
import 'package:fluvita/riverpod/repository/libraries_repository.dart';
import 'package:fluvita/riverpod/repository/reader_repository.dart';
import 'package:fluvita/riverpod/repository/series_repository.dart';
import 'package:fluvita/riverpod/repository/volumes_repository.dart';
import 'package:fluvita/riverpod/repository/want_to_read_repository.dart';
import 'package:fluvita/riverpod/settings.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_manager.freezed.dart';
part 'sync_manager.g.dart';

enum SyncPhase {
  none,
  allSeries,
  seriesDetails,
  onDeck,
  recentlyAdded,
  recentlyUpdated,
  libraries,
  progress,
  covers,
}

@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState.idle() = IdleState;

  const factory SyncState.syncing({required SyncPhase phase}) = SyncingState;

  const factory SyncState.error({
    required SyncPhase phase,
    required Object error,
  }) = ErrorState;
}

@riverpod
class SyncManager extends _$SyncManager {
  bool _hasCredentials = false;
  bool _hasConnection = false;

  @override
  SyncState build() {
    _listenCredentials();
    _listenConnectivity();
    _listenAppLifecycle();
    return const SyncState.idle();
  }

  Future<void> fullSync() async {
    await _syncAllSeries();
    await _syncAllSeriesDetails();
    await Future.wait([
      _syncOnDeck(),
      _syncRecentlyUpdated(),
      _syncRecentlyAdded(),
      _syncLibraries(),
      _syncProgress(),
    ]);

    await _syncCovers();
  }

  Future<void> syncHome() async {
    await Future.wait([
      _syncOnDeck(),
      _syncRecentlyUpdated(),
      _syncRecentlyAdded(),
    ]);
  }

  Future<void> syncLibrary() async {
    await _syncLibraries();
  }

  Future<void> syncProgress() async {
    await _syncProgress();
  }

  Future<void> _syncAllSeries() async {
    await _runPhase(.allSeries, () async {
      final seriesRepo = ref.read(seriesRepositoryProvider);
      final readerRepo = ref.read(readerRepositoryProvider);

      await seriesRepo.refreshAllSeries();
      await readerRepo.refreshContinuePointsAndProgress();
    });
  }

  Future<void> _syncAllSeriesDetails() async {
    await _runPhase(.seriesDetails, () async {
      final seriesRepo = ref.read(seriesRepositoryProvider);

      await seriesRepo.refreshAllSeriesDetails();
    });
  }

  Future<void> _syncLibraries() async {
    await _runPhase(.libraries, () async {
      final librariesRepo = ref.read(librariesRepositoryProvider);
      final wantToReadRepo = ref.read(wantToReadRepositoryProvider);

      await librariesRepo.refreshLibraries();
      await wantToReadRepo.mergeWantToRead();
    });
  }

  Future<void> _syncOnDeck() async {
    await _runPhase(.onDeck, () async {
      state = const SyncState.syncing(phase: .onDeck);
      final seriesRepo = ref.read(seriesRepositoryProvider);

      await seriesRepo.refreshedOnDeck();
    });
  }

  Future<void> _syncRecentlyUpdated() async {
    await _runPhase(.recentlyUpdated, () async {
      state = const SyncState.syncing(phase: .recentlyUpdated);
      final seriesRepo = ref.read(seriesRepositoryProvider);

      await seriesRepo.refreshRecentlyUpdated();
    });
  }

  Future<void> _syncRecentlyAdded() async {
    await _runPhase(.recentlyAdded, () async {
      final seriesRepo = ref.read(seriesRepositoryProvider);

      await seriesRepo.refreshRecentlyAdded();
    });
  }

  Future<void> _syncProgress() async {
    await _runPhase(.progress, () async {
      final readerRepo = ref.read(readerRepositoryProvider);

      await readerRepo.mergeProgress();
    });
  }

  Future<void> _syncCovers() async {
    await _runPhase(.covers, () async {
      final seriesRepo = ref.read(seriesRepositoryProvider);
      final volumesRepo = ref.read(volumesRepositoryProvider);
      final chapterRepo = ref.read(chaptersRepositoryProvider);

      await Future.wait([
        seriesRepo.fetchMissingCovers(),
        volumesRepo.fetchMissingCovers(),
        chapterRepo.fetchMissingCovers(),
      ]);
    });
  }

  Future<void> _runPhase(
    SyncPhase phase,
    FutureOr<void> Function() callback,
  ) async {
    if (!_hasCredentials || !_hasConnection) return;

    state = SyncState.syncing(phase: phase);

    try {
      await callback();
    } catch (e) {
      log.e('failed phase', error: e);
      state = SyncState.error(
        phase: state.whenOrNull(syncing: (phase) => phase) ?? .none,
        error: e,
      );
    }

    state = const SyncState.idle();
  }

  void _listenCredentials() {
    ref.listen(settingsProvider, (prev, next) {
      final creds = next.value;
      if ((creds?.url?.isEmpty ?? true) || (creds?.apiKey?.isEmpty ?? true)) {
        return;
      }

      final prevCreds = prev?.value;
      final firstLoad =
          (prevCreds?.url?.isEmpty ?? true) ||
          (prevCreds?.apiKey?.isEmpty ?? true);
      final changed =
          creds?.url != prevCreds?.url || creds?.apiKey != prevCreds?.apiKey;

      if (firstLoad || changed) fullSync();
      _hasCredentials =
          (creds?.url?.isNotEmpty ?? false) &&
          (creds?.apiKey?.isNotEmpty ?? false);
    });
  }

  void _listenConnectivity() {
    final sub = Connectivity().onConnectivityChanged.listen((results) {
      final isOnline = results.any((r) => r != ConnectivityResult.none);
      if (isOnline && !_hasConnection) fullSync();
      _hasConnection = isOnline;
    });
    ref.onDispose(sub.cancel);
  }

  void _listenAppLifecycle() {
    final observer = _SyncLifecycleObserver(onResume: fullSync);
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
  }
}

class _SyncLifecycleObserver extends WidgetsBindingObserver {
  final void Function() onResume;
  _SyncLifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState appState) {
    if (appState == AppLifecycleState.resumed) onResume();
  }
}
