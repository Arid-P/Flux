import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/hex_color.dart';
import '../../../core/di/injection.dart';
import '../domain/entities.dart';
import 'bloc/habits_cubit.dart';
import 'bloc/habits_state.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late final HabitsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<HabitsCubit>();
    _cubit.loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Habits',
              style: TextStyle(color: tokens.textPrimary)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateDialog,
          backgroundColor: tokens.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: BlocBuilder<HabitsCubit, HabitsState>(
          bloc: _cubit,
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.habits.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.track_changes,
                        size: 64, color: tokens.textSecondary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text('No habits yet',
                        style: TextStyle(
                            fontSize: 18, color: tokens.textSecondary)),
                    const SizedBox(height: 8),
                    Text('Tap + to create a new habit',
                        style: TextStyle(
                            fontSize: 14,
                            color: tokens.textSecondary.withOpacity(0.7))),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.habits.length,
              itemBuilder: (context, index) {
                final habit = state.habits[index];
                final isCompletedToday =
                    state.todayCompletions[habit.id] ?? false;
                final streak = state.streaks[habit.id] ?? 0;

                return _HabitCard(
                  habit: habit,
                  isCompletedToday: isCompletedToday,
                  streak: streak,
                  onToggle: () => _cubit.toggleCompletion(habit.id!),
                  onDelete: () => _cubit.deleteHabit(habit.id!),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    String selectedColor = '2E7D32';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('New Habit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                maxLength: 50,
                decoration: const InputDecoration(hintText: 'Habit name'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  '2E7D32', '1565C0', '43A047', 'FB8C00',
                  'E64A19', 'E53935', '7B1FA2', '00838F',
                ].map((hex) {
                  return GestureDetector(
                    onTap: () =>
                        setDialogState(() => selectedColor = hex),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: HexColor.fromHex(hex),
                        shape: BoxShape.circle,
                        border: selectedColor == hex
                            ? Border.all(color: Colors.white, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  _cubit.createHabit(
                    name: nameCtrl.text.trim(),
                    colorHex: selectedColor,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  final Habit habit;
  final bool isCompletedToday;
  final int streak;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _HabitCard({
    required this.habit,
    required this.isCompletedToday,
    required this.streak,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final habitColor = HexColor.fromHex(habit.colorHex);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: habitColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Completion checkbox
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompletedToday ? habitColor : Colors.transparent,
                border: Border.all(
                  color: habitColor,
                  width: 2,
                ),
              ),
              child: isCompletedToday
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 16),

          // Name and streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.local_fire_department,
                        size: 14, color: streak > 0 ? const Color(0xFFFB8C00) : tokens.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      '$streak day streak',
                      style: TextStyle(
                        fontSize: 12,
                        color: streak > 0
                            ? const Color(0xFFFB8C00)
                            : tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Delete
          IconButton(
            icon: Icon(Icons.more_vert, size: 20, color: tokens.textSecondary),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete_outline,
                            color: Color(0xFFE53935)),
                        title: const Text('Delete habit',
                            style: TextStyle(color: Color(0xFFE53935))),
                        onTap: () {
                          Navigator.pop(ctx);
                          onDelete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
