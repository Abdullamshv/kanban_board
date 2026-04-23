import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/dio_client.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/kanban_repo.dart';

sealed class BoardState {}

class BoardLoading extends BoardState {}

class BoardData extends BoardState {
  final List<TaskModel> tasks;
  final bool isSaving; // ✅ добавь
  BoardData({required this.tasks, this.isSaving = false});
}

class BoardError extends BoardState {
  final String message;
  BoardError({required this.message});
}

class KanbanNotifier extends Notifier<BoardState> {
  late final KanbanRepository _repository;
  List<TaskModel> _backupTasks = [];
  bool _isSaving = false;

  @override
  BoardState build() {
    _repository = ref.watch(kanbanRepositoryProvider);
    _fetchInitialData();
    return BoardLoading();
  }

  Future<void> _fetchInitialData() async {
    final result = await _repository.fetchTasks();
    result.fold((error) => state = BoardError(message: error), (tasks) {
      _backupTasks = List.from(tasks);
      state = BoardData(tasks: tasks);
    });
  }

  void retry() {
    state = BoardLoading();
    _fetchInitialData();
  }

  Future<void> moveTask({
    required TaskModel task,
    required int newParentId,
    required int newOrder,
  }) async {
    if (_isSaving) return;
    _isSaving = true;

    final currentTasks = (state as BoardData).tasks;
    state = BoardData(tasks: currentTasks, isSaving: true);

    try {
      final currentState = state;
      if (currentState is! BoardData) return;

      _backupTasks = List.from(currentState.tasks);
      final newTasks = List<TaskModel>.from(currentState.tasks);

      final taskIndex = newTasks.indexWhere(
        (t) => t.indicatorToMoId == task.indicatorToMoId,
      );
      if (taskIndex == -1) return;

      final oldTask = newTasks[taskIndex];
      final bool parentChanged = oldTask.parentId != newParentId;

      newTasks.removeAt(taskIndex);

      final targetColTasks =
          newTasks.where((t) => t.parentId == newParentId).toList()
            ..sort((a, b) => a.order.compareTo(b.order));

      int insertIndex = targetColTasks.indexWhere((t) => t.order >= newOrder);
      if (insertIndex == -1) insertIndex = targetColTasks.length;

      targetColTasks.insert(
        insertIndex,
        oldTask.copyWith(parentId: newParentId),
      );

      for (int i = 0; i < targetColTasks.length; i++) {
        targetColTasks[i] = targetColTasks[i].copyWith(order: i);
      }

      newTasks.removeWhere((t) => t.parentId == newParentId);
      newTasks.addAll(targetColTasks);
      newTasks.sort((a, b) => a.order.compareTo(b.order));

      state = BoardData(tasks: newTasks);

      final finalUpdatedTask = targetColTasks.firstWhere(
        (t) => t.indicatorToMoId == task.indicatorToMoId,
      );

      bool needRevert = false;

      if (parentChanged) {
        final res = await _repository.updateTaskField(
          taskId: finalUpdatedTask.indicatorToMoId,
          fieldName: 'parent_id',
          fieldValue: newParentId,
        );
        res.mapLeft((_) => needRevert = true);
      }

      if (!needRevert) {
        final res = await _repository.updateTaskField(
          taskId: finalUpdatedTask.indicatorToMoId,
          fieldName: 'order',
          fieldValue: finalUpdatedTask.order,
        );
        res.mapLeft((_) => needRevert = true);
      }

      if (needRevert) {
        state = BoardData(tasks: _backupTasks);
      } else {
        _backupTasks = List.from(newTasks);
      }
    } finally {
      _isSaving = false;
      final currentTasks = (state as BoardData?)?.tasks ?? _backupTasks;
      state = BoardData(tasks: currentTasks, isSaving: false); //
    }
  }
}

final boardProvider = NotifierProvider<KanbanNotifier, BoardState>(() {
  return KanbanNotifier();
});
