import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/task_model.dart';
import '../../providers/board_provider.dart';
import 'kanban_card.dart';

class KanbanColumn extends ConsumerStatefulWidget {
  final int folderId;
  final String folderName;
  final List<TaskModel> tasks;

  const KanbanColumn({
    super.key,
    required this.folderId,
    required this.folderName,
    required this.tasks,
  });

  @override
  ConsumerState<KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends ConsumerState<KanbanColumn> {
  final _listScrollController = ScrollController();

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBECF0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.folderName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172B4D),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.tasks.length}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DragTarget<TaskModel>(
              onWillAcceptWithDetails: (details) =>
                  details.data.parentId != widget.folderId,
              onAcceptWithDetails: (details) {
                ref.read(boardProvider.notifier).moveTask(
                  task: details.data,
                  newParentId: widget.folderId,
                  newOrder: widget.tasks.length,
                );
              },
              builder: (context, candidateData, rejectedData) {
                final isHovered = candidateData.isNotEmpty;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isHovered
                        ? Colors.blue.withValues(alpha: 0.08)
                        : Colors.transparent,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                    border: isHovered
                        ? Border.all(
                            color: Colors.blue.withValues(alpha: 0.4),
                            width: 2,
                          )
                        : null,
                  ),
                  child: widget.tasks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: isHovered ? Colors.blue : Colors.black26,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isHovered ? 'Release to drop' : 'Drop tasks here',
                                style: TextStyle(
                                  color: isHovered
                                      ? Colors.blue
                                      : Colors.black38,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _listScrollController,
                          key: PageStorageKey(widget.folderId),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          itemCount: widget.tasks.length + (isHovered ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (isHovered && index == widget.tasks.length) {
                              return Container(
                                height: 60,
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.4),
                                    width: 2,
                                  ),
                                ),
                              );
                            }

                            final task = widget.tasks[index];

                            return LongPressDraggable<TaskModel>(
                              key: ValueKey(task.indicatorToMoId),
                              data: task,
                              delay: const Duration(milliseconds: 200),
                              feedback: Material(
                                elevation: 12,
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 280,
                                  child: KanbanCard(task: task),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: KanbanCard(task: task),
                              ),
                              child: KanbanCard(task: task),
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}