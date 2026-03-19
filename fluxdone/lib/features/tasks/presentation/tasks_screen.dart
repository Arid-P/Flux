import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/hex_color.dart';
import '../domain/entities.dart';
import 'bloc/tasks_cubit.dart';
import 'bloc/tasks_state.dart';
import '../../../core/di/injection.dart';
import '../../lists/presentation/app_drawer.dart';
import 'task_creation_sheet.dart';
import 'task_detail_sheet.dart';

class TasksScreen extends StatefulWidget {
  final String? listId;
  const TasksScreen({super.key, this.listId});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final TasksCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TasksCubit>();
    _loadTasks();
  }

  void _loadTasks() {
    final id = widget.listId;
    if (id == null) {
      _cubit.loadTasksForSmartList('All');
    } else {
      final numericId = int.tryParse(id);
      if (numericId != null) {
        _cubit.loadTasksForList(numericId);
      } else {
        _cubit.loadTasksForSmartList(id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: BlocBuilder<TasksCubit, TasksState>(
            bloc: _cubit,
            builder: (context, state) {
              return Text(
                state.listName.isNotEmpty ? state.listName : 'All Tasks',
                style: TextStyle(color: tokens.textPrimary),
              );
            },
          ),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => TaskCreationSheet.show(context, listId: _cubit.currentListId),
          backgroundColor: tokens.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: BlocBuilder<TasksCubit, TasksState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.tasks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 64, color: tokens.textSecondary.withOpacity(0.4)),
                    const SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: TextStyle(
                          fontSize: 18, color: tokens.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to create a new task',
                      style: TextStyle(
                          fontSize: 14,
                          color: tokens.textSecondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: state.tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                return _TaskCard(
                  task: state.tasks[index],
                  colorHex: state.colorHex,
                  onToggle: () =>
                      _cubit.toggleComplete(state.tasks[index].id!),
                  onDelete: () =>
                      _cubit.softDeleteTask(state.tasks[index].id!),
                  onTap: () => TaskDetailSheet.show(
                    context, state.tasks[index], state.colorHex),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Task Card ─────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final Task task;
  final String colorHex;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.colorHex,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final listColor = HexColor.fromHex(colorHex);
    final priorityColor = _priorityColor(task.priority);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: listColor, width: 3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? tokens.primary
                          : tokens.textSecondary.withOpacity(0.5),
                      width: 2,
                    ),
                    color: task.isCompleted
                        ? tokens.primary
                        : Colors.transparent,
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        color: task.isCompleted
                            ? tokens.textSecondary
                            : tokens.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.startTime != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time,
                              size: 12, color: tokens.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(task.startTime!),
                            style: TextStyle(
                                fontSize: 12, color: tokens.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (task.priority > 0)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: priorityColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(int priority) {
    switch (priority) {
      case 3:
        return const Color(0xFFE53935);
      case 2:
        return const Color(0xFFFB8C00);
      case 1:
        return const Color(0xFF43A047);
      default:
        return Colors.transparent;
    }
  }

  String _formatTime(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $amPm';
  }
}
