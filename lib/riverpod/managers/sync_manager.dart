import 'package:flutter/widgets.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kover/riverpod/providers/auth.dart';
import 'package:kover/riverpod/providers/connectivity.dart';
import 'package:kover/riverpod/providers/series.dart';
import 'package:kover/riverpod/repository/book_repository.dart';
import 'package:kover/riverpod/repository/chapters_repository.dart';
import 'package:kover/riverpod/repository/libraries_repository.dart';
import 'package:kover/riverpod/repository/reader_repository.dart';
import 'package:kover/riverpod/repository/series_repository.dart';
import 'package:kover/riverpod/repository/volumes_repository.dart';
import 'package:kover/riverpod/repository/want_to_read_repository.dart';
import 'package:kover/utils/lifecycle.dart';
import 'package:kover/utils/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sync_manager.freezed.dart';
part 'sync_manager.g.dart';

enum SyncPhase {
  none,
  allSeries,
  seriesDetails,
  metadata,
  recentlyAdded,
  recentlyUpdated,
  libraries,
  progress,
  covers,
}

@freezed
sealed class SyncState with _$SyncState {
  const factory SyncState.idle() = IdleState;

  const factory SyncState.syncing({required Set<SyncPhase> phases}) =
      SyncingState;

  const factory SyncState.error({
    required SyncPhase phase,
    required Object error,
  }) = ErrorState;
}

@Riverpod(keepAlive: true)
class SyncManager extends _$SyncManager {
  bool _hasUser = false;
  bool _hasConnection = false;
  final Set<SyncPhase> _runningPhases = {};
  SyncEngine get _engine {
    final seriesRepo = ref.read(seriesRepositoryProvider);
    final bookRepo = ref.read(bookRepositoryProvider);
    final librariesRepo = ref.read(librariesRepositoryProvider);
    final wantToReadRepo = ref.read(wantToReadRepositoryProvider);
    final readerRepo = ref.read(readerRepositoryProvider);
    final volumesRepo = ref.read(volumesRepositoryProvider);
    final chaptersRepo = ref.read(chaptersRepositoryProvider);

    return SyncEngine(
      seriesRepo: seriesRepo,
      bookRepo: bookRepo,
      librariesRepo: librariesRepo,
      wantToReadRepo: wantToReadRepo,
      readerRepo: readerRepo,
      volumesRepo: volumesRepo,
      chaptersRepo: chaptersRepo,
    );
  }

  @override
  SyncState build() {
    _hasUser = ref.read(currentUserProvider).hasValue;
    _hasConnection = ref.read(hasConnectionProvider).value ?? false;

    _listenUser();
    _listenConnectivity();
    _listenAppLifecycle();

    return const SyncState.idle();
  }

  /// Perform full sync with server
  Future<void> fullSync() async {
    await _syncAllSeries();

    await Future.wait([
      _syncRecentlyUpdated(),
      _syncRecentlyAdded(),
      syncLibraries(),
      syncProgress(),
      _syncMetadata(),
    ]);

    await _syncCovers();
  }

  /// Sync libraries
  Future<void> syncLibraries() async {
    await _runPhase(.libraries, () async {
      await _engine.syncLibraries();
    });
  }

  /// Sync progress
  Future<void> syncProgress() async {
    await _runPhase(.progress, () async {
      await _engine.syncProgress();
    });
  }

  Future<void> _syncAllSeries() async {
    await _runPhase(.allSeries, () async {
      await _engine.syncAllSeries();
    });
  }

  Future<void> _syncMetadata() async {
    await _runPhase(.metadata, () async {
      await _engine.syncMetadata();
    });
  }

  Future<void> _syncRecentlyUpdated() async {
    await _runPhase(.recentlyUpdated, () async {
      await _engine.syncRecentlyUpdated();
    });
  }

  Future<void> _syncRecentlyAdded() async {
    await _runPhase(.recentlyAdded, () async {
      await _engine.syncRecentlyAdded();
    });
  }

  Future<void> _syncCovers() async {
    await _runPhase(.covers, () async {
      await _engine.syncCovers();
    });
  }

  Future<void> _runPhase(
    SyncPhase phase,
    FutureOr<void> Function() callback,
  ) async {
    if (!_hasUser || !_hasConnection || _runningPhases.contains(phase)) return;

    _runningPhases.add(phase);
    state = SyncState.syncing(phases: Set.unmodifiable(_runningPhases));

    var failed = false;
    try {
      await callback();
    } catch (e) {
      failed = true;
      log.e('failed phase', error: e);
      state = SyncState.error(phase: phase, error: e);
    } finally {
      _runningPhases.remove(phase);
      if (!failed) {
        if (_runningPhases.isEmpty) {
          state = const SyncState.idle();
        } else {
          state = SyncState.syncing(phases: Set.unmodifiable(_runningPhases));
        }
      }
    }
  }

  void _listenUser() {
    ref.listen(currentUserProvider, (prev, next) {
      _hasUser = next.hasValue;
      if (next.hasError) return;
      if (next.hasValue && prev?.value != next.value) {
        fullSync();
      }
    });
  }

  void _listenConnectivity() {
    ref.listen(hasConnectionProvider, (prev, next) {
      next.whenData((good) {
        _hasConnection = good;

        // skip update on first event as we are syncing already
        if (prev != null && good && good != prev.value) {
          fullSync();
        }
      });
    });
  }

  void _listenAppLifecycle() {
    final observer = LifecycleOnResumeObserver(onResume: fullSync);
    WidgetsBinding.instance.addObserver(observer);
    ref.onDispose(() => WidgetsBinding.instance.removeObserver(observer));
  }
}

class SyncEngine {
  final SeriesRepository seriesRepo;
  final BookRepository bookRepo;
  final LibrariesRepository librariesRepo;
  final WantToReadRepository wantToReadRepo;
  final ReaderRepository readerRepo;
  final VolumesRepository volumesRepo;
  final ChaptersRepository chaptersRepo;

  const SyncEngine({
    required this.seriesRepo,
    required this.bookRepo,
    required this.librariesRepo,
    required this.wantToReadRepo,
    required this.readerRepo,
    required this.volumesRepo,
    required this.chaptersRepo,
  });

  Future<void> syncAllSeries() async {
    await seriesRepo.refreshAllSeries();
    await seriesRepo.fetchMissingMetadata();
  }

  Future<void> syncMetadata() async {
    await seriesRepo.fetchMissingMetadata();
    await bookRepo.fetchMissingChaptersTocs();
  }

  Future<void> syncLibraries() async {
    await librariesRepo.refreshLibraries();
    await wantToReadRepo.mergeWantToRead();
  }

  Future<void> syncRecentlyUpdated() async {
    await seriesRepo.refreshRecentlyUpdated();
  }

  Future<void> syncRecentlyAdded() async {
    await seriesRepo.refreshRecentlyAdded();
  }

  Future<void> syncProgress() async {
    await readerRepo.refreshOutdatedProgress();
    await readerRepo.mergeProgress();
  }

  Future<void> syncCovers() async {
    await Future.wait([
      seriesRepo.fetchMissingCovers(),
      volumesRepo.fetchMissingCovers(),
      chaptersRepo.fetchMissingCovers(),
    ]);
  }
}
