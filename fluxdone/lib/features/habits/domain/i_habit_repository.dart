import 'entities.dart';

abstract class IHabitRepository {
  Future<List<Habit>> getAllHabits();
  Future<Habit?> getHabitById(int id);
  Future<int> createHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(int id);
  Future<void> toggleCompletion(int habitId, DateTime date);
  Future<HabitCompletion?> getCompletion(int habitId, DateTime date);
  Future<List<HabitCompletion>> getCompletionsForRange(int habitId, DateTime start, DateTime end);
  Future<int> getCurrentStreak(int habitId);
}
