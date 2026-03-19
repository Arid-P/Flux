import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/hex_color.dart';
import '../../../core/di/injection.dart';
import '../domain/entities.dart';
import 'bloc/tasks_cubit.dart';

class TaskDetailSheet extends StatefulWidget {
  final Task task;
  final String listColorHex;

  const TaskDetailSheet({
    super.key,
    required this.task,
    required this.listColorHex,
  });

  static void show(BuildContext context, Task task, String listColorHex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskDetailSheet(task: task, listColorHex: listColorHex),
    );
  }

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  late bool _isCompleted;
  late int _priority;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _descCtrl = TextEditingController(text: widget.task.descriptionMd ?? '');
    _isCompleted = widget.task.isCompleted;
    _priority = widget.task.priority;

    _titleCtrl.addListener(_markDirty);
    _descCtrl.addListener(_markDirty);
  }

  void _markDirty() => _isDirty = true;

  @override
  void dispose() {
    _autoSave();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _autoSave() {
    if (!_isDirty) return;
    if (_titleCtrl.text.trim().isEmpty) return;

    final updated = widget.task.copyWith(
      title: _titleCtrl.text.trim(),
      descriptionMd: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      isCompleted: _isCompleted,
      priority: _priority,
    );
    getIt<TasksCubit>().updateTaskDirectly(updated);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final listColor = HexColor.fromHex(widget.listColorHex);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 32, height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCompleted = !_isCompleted;
                            _isDirty = true;
                          });
                        },
                        child: Container(
                          width: 22, height: 22,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isCompleted ? tokens.primary : listColor,
                              width: 2,
                            ),
                            color: _isCompleted ? tokens.primary : Colors.transparent,
                          ),
                          child: _isCompleted
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _titleCtrl,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: tokens.textPrimary,
                            decoration: _isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Task title',
                          ),
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Date/time info
                _buildInfoRow(Icons.calendar_today, _formatTaskDate(), tokens),
                if (widget.task.startTime != null)
                  _buildInfoRow(Icons.access_time, _formatTimeRange(), tokens),

                // Priority
                _buildPriorityRow(tokens),

                const Divider(height: 32),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Notes',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: tokens.textSecondary)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _descCtrl,
                    style: TextStyle(fontSize: 15, color: tokens.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Add notes...',
                      hintStyle: TextStyle(color: tokens.textSecondary),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    minLines: 4,
                  ),
                ),

                const Divider(height: 32),

                // Delete button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextButton.icon(
                    onPressed: () {
                      getIt<TasksCubit>().softDeleteTask(widget.task.id!);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
                    label: const Text('Move to Trash',
                        style: TextStyle(color: Color(0xFFE53935))),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String text, ThemeTokens tokens) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: tokens.textSecondary),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 14, color: tokens.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildPriorityRow(ThemeTokens tokens) {
    final labels = ['None', 'Low', 'Medium', 'High'];
    final colors = [
      tokens.textSecondary,
      const Color(0xFF1565C0),
      const Color(0xFFFB8C00),
      const Color(0xFFE53935),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(
            _priority > 0 ? Icons.flag : Icons.flag_outlined,
            size: 18,
            color: colors[_priority],
          ),
          const SizedBox(width: 12),
          Text('Priority: ${labels[_priority]}',
              style: TextStyle(fontSize: 14, color: tokens.textPrimary)),
          const Spacer(),
          PopupMenuButton<int>(
            icon: Icon(Icons.edit, size: 16, color: tokens.textSecondary),
            onSelected: (v) => setState(() {
              _priority = v;
              _isDirty = true;
            }),
            itemBuilder: (_) => [
              for (var i = 3; i >= 0; i--)
                PopupMenuItem(
                  value: i,
                  child: Row(children: [
                    Icon(i > 0 ? Icons.flag : Icons.flag_outlined,
                        size: 18, color: colors[i]),
                    const SizedBox(width: 8),
                    Text(labels[i]),
                  ]),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTaskDate() {
    final dt = DateTime.fromMillisecondsSinceEpoch(widget.task.taskDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    if (target == today) return 'Today';
    if (target == today.add(const Duration(days: 1))) return 'Tomorrow';
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _formatTimeRange() {
    String fmt(int epochMs) {
      final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ap = dt.hour >= 12 ? 'PM' : 'AM';
      return '$h:$m $ap';
    }
    var result = fmt(widget.task.startTime!);
    if (widget.task.endTime != null) {
      result += ' – ${fmt(widget.task.endTime!)}';
    }
    return result;
  }
}
