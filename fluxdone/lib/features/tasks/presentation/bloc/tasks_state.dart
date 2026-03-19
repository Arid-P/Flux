import 'package:equatable/equatable.dart';
import '../../domain/entities.dart';

class TasksState extends Equatable {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final String listName;
  final String colorHex;

  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.listName = '',
    this.colorHex = '2E7D32',
  });

  TasksState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    String? listName,
    String? colorHex,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      listName: listName ?? this.listName,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [tasks, isLoading, error, listName, colorHex];
}
