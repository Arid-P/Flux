import 'package:equatable/equatable.dart';
import '../../domain/entities.dart';

class HabitsState extends Equatable {
  final List<Habit> habits;
  final Map<int, bool> todayCompletions; // habitId -> completed today
  final Map<int, int> streaks; // habitId -> current streak
  final bool isLoading;
  final String? error;

  const HabitsState({
    this.habits = const [],
    this.todayCompletions = const {},
    this.streaks = const {},
    this.isLoading = false,
    this.error,
  });

  HabitsState copyWith({
    List<Habit>? habits,
    Map<int, bool>? todayCompletions,
    Map<int, int>? streaks,
    bool? isLoading,
    String? error,
  }) {
    return HabitsState(
      habits: habits ?? this.habits,
      todayCompletions: todayCompletions ?? this.todayCompletions,
      streaks: streaks ?? this.streaks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [habits, todayCompletions, streaks, isLoading, error];
}
