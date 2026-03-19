import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/i_habit_repository.dart';
import '../../domain/entities.dart';
import 'habits_state.dart';

@injectable
class HabitsCubit extends Cubit<HabitsState> {
  final IHabitRepository _repo;
  HabitsCubit(this._repo) : super(const HabitsState());

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true));
    try {
      final habits = await _repo.getAllHabits();
      final Map<int, bool> completions = {};
      final Map<int, int> streaks = {};
      
      for (final h in habits) {
        final comp = await _repo.getCompletion(h.id!, DateTime.now());
        completions[h.id!] = comp != null;
        streaks[h.id!] = await _repo.getCurrentStreak(h.id!);
      }
      
      emit(state.copyWith(
        habits: habits,
        todayCompletions: completions,
        streaks: streaks,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> toggleCompletion(int habitId) async {
    try {
      await _repo.toggleCompletion(habitId, DateTime.now());
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> createHabit({
    required String name,
    required String colorHex,
    String frequencyRule = 'daily',
    int targetCount = 1,
  }) async {
    try {
      final habit = Habit(
        name: name,
        colorHex: colorHex,
        frequencyRule: frequencyRule,
        targetCount: targetCount,
      );
      await _repo.createHabit(habit);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteHabit(int habitId) async {
    try {
      await _repo.deleteHabit(habitId);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
