import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/di/injection.dart';
import '../domain/entities.dart';
import 'bloc/tasks_cubit.dart';
import 'bloc/tasks_state.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late final TasksCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TasksCubit>();
    _cubit.loadTasksForSmartList('Trash');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Trash'),
          actions: [
            BlocBuilder<TasksCubit, TasksState>(
              bloc: _cubit,
              builder: (context, state) {
                if (state.tasks.isEmpty) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () => _confirmEmptyTrash(),
                  child: const Text('Empty Trash',
                      style: TextStyle(color: Color(0xFFE53935))),
                );
              },
            ),
          ],
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
                    Icon(Icons.delete_outline,
                        size: 64, color: tokens.textSecondary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('Trash is empty',
                        style: TextStyle(
                            fontSize: 18, color: tokens.textSecondary)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.tasks.length,
              itemBuilder: (context, index) {
                final task = state.tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    title: Text(
                      task.title,
                      style: TextStyle(
                        color: tokens.textSecondary,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: task.trashedAt != null
                        ? Text(
                            'Trashed ${_formatDate(task.trashedAt!)}',
                            style: TextStyle(
                                fontSize: 12, color: tokens.textSecondary),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.restore,
                              color: tokens.primary, size: 20),
                          tooltip: 'Restore',
                          onPressed: () async {
                            await _cubit.restoreTask(task.id!);
                            _cubit.loadTasksForSmartList('Trash');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_forever,
                              color: Color(0xFFE53935), size: 20),
                          tooltip: 'Delete permanently',
                          onPressed: () async {
                            await _cubit.permanentlyDeleteTask(task.id!);
                            _cubit.loadTasksForSmartList('Trash');
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _confirmEmptyTrash() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Empty trash?'),
        content: const Text(
            'All trashed tasks will be permanently deleted. This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _cubit.emptyTrash();
              _cubit.loadTasksForSmartList('Trash');
            },
            child: const Text('Empty',
                style: TextStyle(color: Color(0xFFE53935))),
          ),
        ],
      ),
    );
  }

  String _formatDate(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}
