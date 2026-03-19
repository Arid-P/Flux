import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/di/injection.dart';
import '../../tasks/presentation/bloc/tasks_cubit.dart';
import '../../tasks/presentation/bloc/tasks_state.dart';
import '../../tasks/presentation/task_creation_sheet.dart';
import '../../lists/presentation/app_drawer.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final TasksCubit _cubit;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  int _viewMode = 0; // 0=day, 1=3-day, 2=week

  final List<String> _viewLabels = ['Day', '3 Day', 'Week'];

  @override
  void initState() {
    super.initState();
    _cubit = getIt<TasksCubit>();
    _loadDayTasks();
  }

  void _loadDayTasks() {
    _cubit.loadTasksForSmartList('Today');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        drawer: const AppDrawer(),
        appBar: AppBar(
          title: Text(_formatMonthYear(_focusedDay),
              style: TextStyle(color: tokens.textPrimary)),
          leading: Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          actions: [
            // View mode toggle
            SegmentedButton<int>(
              segments: [
                for (int i = 0; i < 3; i++)
                  ButtonSegment(value: i, label: Text(_viewLabels[i])),
              ],
              selected: {_viewMode},
              onSelectionChanged: (v) => setState(() => _viewMode = v.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(
                    TextStyle(fontSize: 11, color: tokens.textPrimary)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.today, color: tokens.textSecondary),
              onPressed: () => setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => TaskCreationSheet.show(context, date: _selectedDay),
          backgroundColor: tokens.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            // Mini calendar header
            _buildWeekStrip(tokens),
            const Divider(height: 1),
            // Timeline body
            Expanded(child: _buildTimeline(tokens)),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekStrip(ThemeTokens tokens) {
    final startOfWeek = _focusedDay.subtract(
        Duration(days: _focusedDay.weekday - 1));

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: tokens.textSecondary),
            onPressed: () => setState(() =>
                _focusedDay = _focusedDay.subtract(const Duration(days: 7))),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final day = startOfWeek.add(Duration(days: i));
                final isSelected = _isSameDay(day, _selectedDay);
                final isToday = _isSameDay(day, DateTime.now());
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                        style: TextStyle(
                          fontSize: 11,
                          color: tokens.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? tokens.primary
                              : isToday
                                  ? tokens.primary.withOpacity(0.15)
                                  : Colors.transparent,
                          border: isToday && !isSelected
                              ? Border.all(color: tokens.primary, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected
                                  ? Colors.white
                                  : tokens.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: tokens.textSecondary),
            onPressed: () => setState(() =>
                _focusedDay = _focusedDay.add(const Duration(days: 7))),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(ThemeTokens tokens) {
    return BlocBuilder<TasksCubit, TasksState>(
      bloc: _cubit,
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: 24,
          itemBuilder: (context, hour) {
            final hourTasks = state.tasks.where((t) {
              if (t.startTime == null) return false;
              final dt = DateTime.fromMillisecondsSinceEpoch(t.startTime!);
              return dt.hour == hour;
            }).toList();

            return Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                      color: tokens.divider.withOpacity(0.3), width: 0.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 48,
                    child: Text(
                      _formatHour(hour),
                      style: TextStyle(
                          fontSize: 11, color: tokens.textSecondary),
                    ),
                  ),
                  Expanded(
                    child: hourTasks.isEmpty
                        ? GestureDetector(
                            onTap: () => TaskCreationSheet.show(
                              context,
                              date: _selectedDay,
                              startTime: TimeOfDay(hour: hour, minute: 0),
                            ),
                            child: Container(color: Colors.transparent),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: hourTasks.map((task) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 2),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      tokens.primary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border(
                                    left: BorderSide(
                                        color: tokens.primary, width: 3),
                                  ),
                                ),
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: tokens.textPrimary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatMonthYear(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12 AM';
    if (hour < 12) return '$hour AM';
    if (hour == 12) return '12 PM';
    return '${hour - 12} PM';
  }
}
