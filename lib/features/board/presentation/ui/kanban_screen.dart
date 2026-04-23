import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/board_provider.dart';
import '../../data/models/task_model.dart';
import 'widgets/kanban_column.dart';

class KanbanScreen extends ConsumerStatefulWidget {
  const KanbanScreen({super.key});

  @override
  ConsumerState<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends ConsumerState<KanbanScreen> {
  final _scrollController = ScrollController();
  List<int>? _folderOrder;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Map<int, String> _extractFolders(List<TaskModel> tasks) {
    final Map<int, String> folders = {};
    for (var task in tasks) {
      if (!folders.containsKey(task.parentId)) {
        final parentIndicator = tasks
            .where((t) => t.indicatorToMoId == task.parentId)
            .firstOrNull;
        folders[task.parentId] = parentIndicator?.name ??
            (task.parentName.isNotEmpty
                ? task.parentName
                : 'Folder ${task.parentId}');
      }
    }
    return folders;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(boardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'KPI Drive Board',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: switch (state) {
        BoardLoading() => const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        BoardError(:final message) => _buildError(message),
        BoardData(:final tasks) => _buildBoard(tasks),
      },
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(fontSize: 16, color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => ref.read(boardProvider.notifier).retry(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard(List<TaskModel> tasks) {
    if (tasks.isEmpty) {
      return const Center(
        child: Text('No tasks found.', style: TextStyle(color: Colors.white)),
      );
    }

    final folders = _extractFolders(tasks);
    _folderOrder ??= folders.keys.toList();

    final orderedFolderIds = _folderOrder!
        .where((id) => folders.containsKey(id))
        .toList();

    final folderIds = folders.keys.toSet();
    final cards = tasks
        .where((t) => !folderIds.contains(t.indicatorToMoId))
        .toList();

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ScrollConfiguration(
        behavior: _KanbanScrollBehavior(),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: orderedFolderIds.map((folderId) {
              final folderName = folders[folderId] ?? 'Unknown';
              final columnCards =
                  cards.where((c) => c.parentId == folderId).toList();

              return KanbanColumn(
                key: ValueKey(folderId),
                folderId: folderId,
                folderName: folderName,
                tasks: columnCards,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _KanbanScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}