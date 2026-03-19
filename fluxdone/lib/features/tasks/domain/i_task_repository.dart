import 'entities.dart';

abstract class ITaskRepository {
  // Core CRUD
  Future<int> createTask(Task task);
  Future<void> updateTask(Task task);
  Future<Task?> getTaskById(int id);
  Future<List<Task>> getTasksByListId(int listId, {bool includeCompleted = false});
  Future<List<Task>> getTasksBySectionId(int sectionId);

  // Smart list queries
  Future<List<Task>> getTasksForToday();
  Future<List<Task>> getTasksForTomorrow();
  Future<List<Task>> getUpcomingTasks(int days);
  Future<List<Task>> getAllIncompleteTasks();
  Future<List<Task>> getCompletedTasks();
  Future<List<Task>> getTrashedTasks();

  // Task count queries
  Future<int> getIncompleteTaskCountByListId(int listId);

  // Task state operations
  Future<void> toggleComplete(int taskId);
  Future<void> softDeleteTask(int taskId);
  Future<void> restoreTask(int taskId);
  Future<void> permanentlyDeleteTask(int taskId);
  Future<void> emptyTrash();

  // Subtask CRUD
  Future<int> createSubtask(Subtask subtask);
  Future<void> updateSubtask(Subtask subtask);
  Future<void> deleteSubtask(int subtaskId);
  Future<void> toggleSubtaskComplete(int subtaskId);
  Future<List<Subtask>> getSubtasksByTaskId(int taskId);

  // Reminder CRUD
  Future<int> createReminder(Reminder reminder);
  Future<void> deleteReminder(int reminderId);
  Future<List<Reminder>> getRemindersByTaskId(int taskId);
}
