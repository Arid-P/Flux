import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/hex_color.dart';
import '../../../core/di/injection.dart';
import '../../lists/domain/entities.dart' as list_entities;
import '../../lists/presentation/bloc/lists_cubit.dart';
import '../../lists/presentation/bloc/lists_state.dart';
import 'bloc/tasks_cubit.dart';

class TaskCreationSheet extends StatefulWidget {
  final int? prefilledListId;
  final DateTime? prefilledDate;
  final TimeOfDay? prefilledStartTime;

  const TaskCreationSheet({
    super.key,
    this.prefilledListId,
    this.prefilledDate,
    this.prefilledStartTime,
  });

  static void show(BuildContext context, {
    int? listId,
    DateTime? date,
    TimeOfDay? startTime,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TaskCreationSheet(
        prefilledListId: listId,
        prefilledDate: date,
        prefilledStartTime: startTime,
      ),
    );
  }

  @override
  State<TaskCreationSheet> createState() => _TaskCreationSheetState();
}

class _TaskCreationSheetState extends State<TaskCreationSheet> {
  final _titleController = TextEditingController();
  final _titleFocus = FocusNode();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  int? _selectedListId;
  String _selectedListName = '';
  String _selectedListColor = '2E7D32';
  int _priority = 0;
  bool _titleError = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.prefilledDate ?? DateTime.now();
    _startTime = widget.prefilledStartTime;
    _selectedListId = widget.prefilledListId;

    // Load list info
    final listsState = context.read<ListsCubit>().state;
    if (_selectedListId != null) {
      _resolveListInfo(listsState);
    } else if (listsState.folders.isNotEmpty) {
      // Default to first list of first folder
      for (final folder in listsState.folders) {
        final lists = listsState.listsByFolder[folder.id] ?? [];
        if (lists.isNotEmpty) {
          _selectedListId = lists.first.id;
          _selectedListName = lists.first.name;
          _selectedListColor = lists.first.colorHex;
          break;
        }
      }
    }
  }

  void _resolveListInfo(ListsState state) {
    for (final folder in state.folders) {
      final lists = state.listsByFolder[folder.id] ?? [];
      for (final list in lists) {
        if (list.id == _selectedListId) {
          _selectedListName = list.name;
          _selectedListColor = list.colorHex;
          return;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final listColor = HexColor.fromHex(_selectedListColor);

    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: tokens.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Title row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Checkbox (unchecked)
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: listColor, width: 2),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _titleController,
                            focusNode: _titleFocus,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 16,
                              color: tokens.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Task title',
                              hintStyle: TextStyle(color: tokens.textSecondary),
                              border: InputBorder.none,
                              enabledBorder: _titleError
                                  ? UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red.shade400))
                                  : InputBorder.none,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata row
                  SizedBox(
                    height: 40,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildDateChip(tokens),
                          const SizedBox(width: 8),
                          if (_selectedDate != null) ...[
                            _buildTimeChip(tokens),
                            const SizedBox(width: 8),
                          ],
                          if (_startTime != null) ...[
                            _buildEndTimeChip(tokens),
                            const SizedBox(width: 8),
                          ],
                          _buildListChip(tokens),
                          const SizedBox(width: 8),
                          _buildPriorityButton(tokens),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Submit button row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton.small(
                          onPressed: _submit,
                          backgroundColor: tokens.primary,
                          child: const Icon(Icons.send, size: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Chips ────────────────────────────────────────────────
  Widget _buildDateChip(ThemeTokens tokens) {
    final label = _selectedDate != null
        ? _formatDate(_selectedDate!)
        : 'Date';
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      avatar: Icon(Icons.calendar_today, size: 14, color: tokens.textSecondary),
      selected: _selectedDate != null,
      onSelected: (_) => _pickDate(),
      backgroundColor: tokens.textSecondary.withOpacity(0.1),
      selectedColor: HexColor.fromHex(_selectedListColor).withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildTimeChip(ThemeTokens tokens) {
    final label = _startTime != null
        ? _startTime!.format(context)
        : 'Time';
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      avatar: Icon(Icons.access_time, size: 14, color: tokens.textSecondary),
      selected: _startTime != null,
      onSelected: (_) => _pickStartTime(),
      backgroundColor: tokens.textSecondary.withOpacity(0.1),
      selectedColor: HexColor.fromHex(_selectedListColor).withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildEndTimeChip(ThemeTokens tokens) {
    final label = _endTime != null
        ? _endTime!.format(context)
        : 'End time';
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 13)),
      avatar: Icon(Icons.timelapse, size: 14, color: tokens.textSecondary),
      selected: _endTime != null,
      onSelected: (_) => _pickEndTime(),
      backgroundColor: tokens.textSecondary.withOpacity(0.1),
      selectedColor: HexColor.fromHex(_selectedListColor).withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildListChip(ThemeTokens tokens) {
    return FilterChip(
      label: Text(
        _selectedListName.isNotEmpty ? _selectedListName : 'List',
        style: const TextStyle(fontSize: 13),
      ),
      avatar: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: HexColor.fromHex(_selectedListColor),
          shape: BoxShape.circle,
        ),
      ),
      selected: _selectedListId != null,
      onSelected: (_) => _pickList(),
      backgroundColor: tokens.textSecondary.withOpacity(0.1),
      selectedColor: HexColor.fromHex(_selectedListColor).withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildPriorityButton(ThemeTokens tokens) {
    final colors = [
      tokens.textSecondary,       // 0 none
      const Color(0xFF1565C0),    // 1 low
      const Color(0xFFFB8C00),    // 2 medium
      const Color(0xFFE53935),    // 3 high
    ];
    return PopupMenuButton<int>(
      icon: Icon(
        _priority > 0 ? Icons.flag : Icons.flag_outlined,
        size: 20,
        color: colors[_priority],
      ),
      onSelected: (value) => setState(() => _priority = value),
      itemBuilder: (_) => [
        _priorityItem(3, 'High', Icons.flag, const Color(0xFFE53935)),
        _priorityItem(2, 'Medium', Icons.flag, const Color(0xFFFB8C00)),
        _priorityItem(1, 'Low', Icons.flag, const Color(0xFF1565C0)),
        _priorityItem(0, 'None', Icons.flag_outlined, tokens.textSecondary),
      ],
    );
  }

  PopupMenuItem<int> _priorityItem(int value, String label, IconData icon, Color color) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }

  // ── Pickers ──────────────────────────────────────────────
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      if (_startTime != null) {
        final startMin = _startTime!.hour * 60 + _startTime!.minute;
        final endMin = picked.hour * 60 + picked.minute;
        if (endMin <= startMin) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('End time must be after start time.')),
            );
          }
          return;
        }
      }
      setState(() => _endTime = picked);
    }
  }

  Future<void> _pickList() async {
    final listsState = context.read<ListsCubit>().state;
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.65,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 32, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Move to list',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    for (final folder in listsState.folders) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Text(
                          folder.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(ctx)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ),
                      for (final list
                          in listsState.listsByFolder[folder.id] ?? [])
                        ListTile(
                          leading: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: HexColor.fromHex(list.colorHex),
                              shape: BoxShape.circle,
                            ),
                          ),
                          title: Text(list.name),
                          trailing: list.id == _selectedListId
                              ? Icon(Icons.check,
                                  size: 20,
                                  color: Theme.of(ctx).primaryColor)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedListId = list.id;
                              _selectedListName = list.name;
                              _selectedListColor = list.colorHex;
                            });
                            Navigator.pop(ctx);
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Submit ───────────────────────────────────────────────
  void _submit() {
    if (_titleController.text.trim().isEmpty) {
      setState(() => _titleError = true);
      Future.delayed(const Duration(milliseconds: 300),
          () => setState(() => _titleError = false));
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a date for this task.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    if (_selectedListId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a list.')),
      );
      return;
    }

    int? startMs;
    int? endMs;
    if (_startTime != null && _selectedDate != null) {
      startMs = DateTime(_selectedDate!.year, _selectedDate!.month,
              _selectedDate!.day, _startTime!.hour, _startTime!.minute)
          .millisecondsSinceEpoch;
    }
    if (_endTime != null && _selectedDate != null) {
      endMs = DateTime(_selectedDate!.year, _selectedDate!.month,
              _selectedDate!.day, _endTime!.hour, _endTime!.minute)
          .millisecondsSinceEpoch;
    }

    final cubit = getIt<TasksCubit>();
    cubit.createTask(
      listId: _selectedListId!,
      title: _titleController.text.trim(),
      date: _selectedDate!,
      startTime: startMs,
      endTime: endMs,
      priority: _priority,
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Task added to $_selectedListName')),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(d.year, d.month, d.day);
    if (target == today) return 'Today';
    if (target == today.add(const Duration(days: 1))) return 'Tomorrow';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}';
  }
}
