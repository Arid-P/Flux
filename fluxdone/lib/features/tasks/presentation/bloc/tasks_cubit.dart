import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/i_task_repository.dart';
import '../../domain/entities.dart';
import '../../../lists/domain/i_list_repository.dart';
import 'tasks_state.dart';

@injectable
class TasksCubit extends Cubit<TasksState> {
  final ITaskRepository _taskRepo;
  final IListRepository _listRepo;
  int? _currentListId;

  TasksCubit(this._taskRepo, this._listRepo) : super(const TasksState());

  int? get currentListId => _currentListId;

  Future<void> loadTasksForList(int listId) async {
    _currentListId = listId;
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final tasks = await _taskRepo.getTasksByListId(listId);
      final name = await _listRepo.getListNameById(listId);
      final color = await _listRepo.getColorHexByListId(listId);
      emit(state.copyWith(
        tasks: tasks,
        isLoading: false,
        listName: name,
        colorHex: color,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> loadTasksForSmartList(String smartListType) async {
    _currentListId = null;
    emit(state.copyWith(isLoading: true, error: null, listName: smartListType));
    try {
      List<Task> tasks;
      switch (smartListType.toLowerCase()) {
        case 'today':
          tasks = await _taskRepo.getTasksForToday();
          break;
        case 'tomorrow':
          tasks = await _taskRepo.getTasksForTomorrow();
          break;
        case 'upcoming':
          tasks = await _taskRepo.getUpcomingTasks(7);
          break;
        case 'all':
          tasks = await _taskRepo.getAllIncompleteTasks();
          break;
        case 'completed':
          tasks = await _taskRepo.getCompletedTasks();
          break;
        case 'trash':
          tasks = await _taskRepo.getTrashedTasks();
          break;
        default:
          tasks = [];
      }
      emit(state.copyWith(tasks: tasks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> createTask({
    required int listId,
    required String title,
    required DateTime date,
    int? startTime,
    int? endTime,
    int priority = 0,
    int? sectionId,
  }) async {
    try {
      final task = Task(
        listId: listId,
        title: title,
        taskDate: date.millisecondsSinceEpoch,
        startTime: startTime,
        endTime: endTime,
        priority: priority,
        sectionId: sectionId,
      );
      await _taskRepo.createTask(task);
      // Refresh current view
      if (_currentListId != null) {
        await loadTasksForList(_currentListId!);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> toggleComplete(int taskId) async {
    try {
      await _taskRepo.toggleComplete(taskId);
      if (_currentListId != null) {
        await loadTasksForList(_currentListId!);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> softDeleteTask(int taskId) async {
    try {
      await _taskRepo.softDeleteTask(taskId);
      if (_currentListId != null) {
        await loadTasksForList(_currentListId!);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> restoreTask(int taskId) async {
    try {
      await _taskRepo.restoreTask(taskId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> permanentlyDeleteTask(int taskId) async {
    try {
      await _taskRepo.permanentlyDeleteTask(taskId);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> emptyTrash() async {
    try {
      await _taskRepo.emptyTrash();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateTaskDirectly(Task task) async {
    try {
      await _taskRepo.updateTask(task);
      if (_currentListId != null) {
        await loadTasksForList(_currentListId!);
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
