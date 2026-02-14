import 'package:fluvita/api/openapi.swagger.dart';
import 'package:fluvita/riverpod/api/client.dart';
import 'package:fluvita/riverpod/storage.dart';
import 'package:fluvita/utils/logging.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hooks_riverpod/experimental/persist.dart';

part 'report_queue.freezed.dart';
part 'report_queue.g.dart';

@freezed
sealed class QueueEvent with _$QueueEvent {
  const QueueEvent._();

  const factory QueueEvent.saveProgress({required ProgressDto body}) =
      SaveProgressEvent;

  factory QueueEvent.fromJson(Map<String, dynamic> json) =>
      _$QueueEventFromJson(json);
}

@freezed
sealed class EventQueueState with _$EventQueueState {
  const EventQueueState._();

  const factory EventQueueState({@Default([]) List<QueueEvent> events}) =
      _EventQueueState;

  factory EventQueueState.fromJson(Map<String, dynamic> json) =>
      _$EventQueueStateFromJson(json);
}

@riverpod
@JsonPersist()
class EventQueue extends _$EventQueue {
  @override
  Future<EventQueueState> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value ?? const EventQueueState();
  }

  Future<void> enqueue(QueueEvent event) async {
    final current = await future;
    state = AsyncData(current.copyWith(events: [...current.events, event]));
  }

  Future<void> dequeue() async {
    final current = await future;
    if (current.events.isEmpty) return;

    state = AsyncData(current.copyWith(events: current.events.sublist(1)));
  }
}

@riverpod
class QueueWorker extends _$QueueWorker {
  @override
  void build() {
    ref.listen(eventQueueProvider, (previous, next) async {
      if (!next.hasValue || next.value!.events.isEmpty) return;

      final event = next.value!.events.first;

      final success = await event.when(saveProgress: _onProgressEvent);

      if (success) {
        await ref.read(eventQueueProvider.notifier).dequeue();
      } else {
        throw Exception('could not process event');
      }
    });
  }

  Future<bool> _onProgressEvent(ProgressDto event) async {
    log.d('processing progress event $event');

    final client = ref.read(restClientProvider);
    final result = await client.apiReaderProgressPost(
      body: event,
    );
    return result.isSuccessful;
  }
}
