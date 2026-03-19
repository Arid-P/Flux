import 'package:injectable/injectable.dart';
import '../../../core/database/database_helper.dart';
import '../domain/i_habit_repository.dart';
import '../domain/entities.dart';

@LazySingleton(as: IHabitRepository)
class HabitRepositoryImpl implements IHabitRepository {
  final DatabaseHelper dbHelper;
  HabitRepositoryImpl(this.dbHelper);

  int _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;

  @override
  Future<List<Habit>> getAllHabits() async {
    final db = await dbHelper.database;
    final maps = await db.query('habits', where: 'is_active = 1', orderBy: 'created_at ASC');
    return maps.map((m) => Habit.fromMap(m)).toList();
  }

  @override
  Future<Habit?> getHabitById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('habits', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Habit.fromMap(result.first);
  }

  @override
  Future<int> createHabit(Habit habit) async {
    final db = await dbHelper.database;
    return await db.insert('habits', habit.toMap());
  }

  @override
  Future<void> updateHabit(Habit habit) async {
    final db = await dbHelper.database;
    await db.update('habits', habit.toMap(), where: 'id = ?', whereArgs: [habit.id]);
  }

  @override
  Future<void> deleteHabit(int id) async {
    final db = await dbHelper.database;
    await db.delete('habits', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> toggleCompletion(int habitId, DateTime date) async {
    final db = await dbHelper.database;
    final dayMs = _startOfDay(date);
    final existing = await db.query('habit_completions',
        where: 'habit_id = ? AND completed_date = ?',
        whereArgs: [habitId, dayMs]);
    
    if (existing.isEmpty) {
      await db.insert('habit_completions', {
        'habit_id': habitId,
        'completed_date': dayMs,
        'completion_count': 1,
      });
    } else {
      await db.delete('habit_completions',
          where: 'habit_id = ? AND completed_date = ?',
          whereArgs: [habitId, dayMs]);
    }
  }

  @override
  Future<HabitCompletion?> getCompletion(int habitId, DateTime date) async {
    final db = await dbHelper.database;
    final dayMs = _startOfDay(date);
    final result = await db.query('habit_completions',
        where: 'habit_id = ? AND completed_date = ?',
        whereArgs: [habitId, dayMs]);
    if (result.isEmpty) return null;
    return HabitCompletion.fromMap(result.first);
  }

  @override
  Future<List<HabitCompletion>> getCompletionsForRange(
      int habitId, DateTime start, DateTime end) async {
    final db = await dbHelper.database;
    final maps = await db.query('habit_completions',
        where: 'habit_id = ? AND completed_date >= ? AND completed_date <= ?',
        whereArgs: [habitId, _startOfDay(start), _startOfDay(end)],
        orderBy: 'completed_date ASC');
    return maps.map((m) => HabitCompletion.fromMap(m)).toList();
  }

  @override
  Future<int> getCurrentStreak(int habitId) async {
    final db = await dbHelper.database;
    int streak = 0;
    DateTime day = DateTime.now();
    while (true) {
      final dayMs = _startOfDay(day);
      final result = await db.query('habit_completions',
          where: 'habit_id = ? AND completed_date = ?',
          whereArgs: [habitId, dayMs]);
      if (result.isEmpty) break;
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }
}
