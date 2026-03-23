import 'package:injectable/injectable.dart';
import '../../../core/database/database_helper.dart';
import '../domain/i_task_repository.dart';
import '../domain/entities.dart';
import '../../../core/notifications/notification_service.dart';
import '../../fluxfoxus_bridge/data/fluxfocus_bridge_service.dart';
import '../../fluxfoxus_bridge/domain/focus_block_request.dart';

@LazySingleton(as: ITaskRepository)
class TaskRepositoryImpl implements ITaskRepository {
  final DatabaseHelper dbHelper;
  final NotificationService notificationService;
  final FluxFocusBridgeService bridgeService;

  TaskRepositoryImpl(this.dbHelper, this.notificationService, this.bridgeService);

  void _syncTaskToFluxFocus(Task task, String action) {
    int duration = 0;
    if (task.startTime != null && task.endTime != null) {
      duration = (task.endTime! - task.startTime!) ~/ 60000;
    }

    final request = FocusBlockRequest(
      taskId: task.id.toString(),
      taskName: task.title,
      startTime: task.startTime != null 
          ? DateTime.fromMillisecondsSinceEpoch(task.startTime!) 
          : null,
      endTime: task.endTime != null 
          ? DateTime.fromMillisecondsSinceEpoch(task.endTime!) 
          : null,
      duration: duration,
      listId: task.listId.toString(),
      sectionId: task.sectionId?.toString(),
      action: action,
    );
    bridgeService.sendFocusBlockRequest(request);
  }




  // ── Helpers ──────────────────────────────────────────────
  int _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;

  int _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59, 999).millisecondsSinceEpoch;

  // ── Core CRUD ───────────────────────────────────────────
  @override
  Future<int> createTask(Task task) async {
    final db = await dbHelper.database;
    final id = await db.insert('tasks', task.toMap());
    final newTask = task.copyWith(id: id);
    _syncTaskToFluxFocus(newTask, 'create');
    return id;
  }

  @override
  Future<void> updateTask(Task task) async {
    final db = await dbHelper.database;
    final map = task.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.update('tasks', map, where: 'id = ?', whereArgs: [task.id]);
    _syncTaskToFluxFocus(task, 'update');
  }

  @override
  Future<Task?> getTaskById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Task.fromMap(result.first);
  }

  @override
  Future<List<Task>> getTasksByListId(int listId, {bool includeCompleted = false}) async {
    final db = await dbHelper.database;
    String where = 'list_id = ? AND is_trashed = 0';
    if (!includeCompleted) where += ' AND is_completed = 0';
    final maps = await db.query('tasks', where: where, whereArgs: [listId], orderBy: 'is_pinned DESC, sort_order ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  @override
  Future<List<Task>> getTasksBySectionId(int sectionId) async {
    final db = await dbHelper.database;
    final maps = await db.query('tasks',
        where: 'section_id = ? AND is_trashed = 0 AND is_completed = 0',
        whereArgs: [sectionId],
        orderBy: 'sort_order ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  // ── Smart Lists ─────────────────────────────────────────
  @override
  Future<List<Task>> getTasksForToday() async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final maps = await db.query('tasks',
        where: 'task_date >= ? AND task_date <= ? AND is_trashed = 0 AND is_completed = 0',
        whereArgs: [_startOfDay(now), _endOfDay(now)],
        orderBy: 'start_time ASC, sort_order ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  @override
  Future<List<Task>> getTasksForTomorrow() async {
    final db = await dbHelper.database;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final maps = await db.query('tasks',
        where: 'task_date >= ? AND task_date <= ? AND is_trashed = 0 AND is_completed = 0',
        whereArgs: [_startOfDay(tomorrow), _endOfDay(tomorrow)],
        orderBy: 'start_time ASC, sort_order ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  @override
  Future<List<Task>> getUpcomingTasks(int days) async {
    final db = await dbHelper.database;
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    final maps = await db.query('tasks',
        where: 'task_date >= ? AND task_date <= ? AND is_trashed = 0 AND is_completed = 0',
        whereArgs: [_startOfDay(now), _endOfDay(end)],
        orderBy: 'task_date ASC, start_time ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  @override
  Future<List<Task>> getAllIncompleteTasks() async {
    final db = await dbHelper.database;
    final maps = await db.query('tasks',
        where: 'is_trashed = 0 AND is_completed = 0',
        orderBy: 'task_date ASC, sort_order ASC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  @override
  Future<List<Task>> getCompletedTasks() async {
    final db = await dbHelper.database;
    final maps = await db.query('tasks',
        where: 'is_completed = 1 AND is_trashed = 0',
        orderBy: 'completed_at DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  @override
  Future<List<Task>> getTrashedTasks() async {
    final db = await dbHelper.database;
    final maps = await db.query('tasks',
        where: 'is_trashed = 1',
        orderBy: 'trashed_at DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  // ── Count ───────────────────────────────────────────────
  @override
  Future<int> getIncompleteTaskCountByListId(int listId) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as cnt FROM tasks WHERE list_id = ? AND is_trashed = 0 AND is_completed = 0',
      [listId],
    );
    return result.first['cnt'] as int;
  }

  // ── Task State ──────────────────────────────────────────
  @override
  Future<void> toggleComplete(int taskId) async {
    final db = await dbHelper.database;
    final task = await getTaskById(taskId);
    if (task == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updatedTask = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? now : null,
    );
    await db.update(
      'tasks',
      updatedTask.toMap(),
      where: 'id = ?',
      whereArgs: [taskId],
    );
    _syncTaskToFluxFocus(updatedTask, 'update');
  }

  @override
  Future<void> softDeleteTask(int taskId) async {
    final db = await dbHelper.database;
    final task = await getTaskById(taskId);
    if (task == null) return;
    
    final now = DateTime.now().millisecondsSinceEpoch;
    final trashedTask = task.copyWith(isTrashed: true, trashedAt: now);
    await db.update(
      'tasks',
      trashedTask.toMap(),
      where: 'id = ?',
      whereArgs: [taskId],
    );

    // Cancel all reminders for this task
    final reminders = await getRemindersByTaskId(taskId);
    for (final r in reminders) {
      await notificationService.cancelNotification(r.notificationId);
    }
    
    _syncTaskToFluxFocus(trashedTask, 'delete');
  }

  @override
  Future<void> restoreTask(int taskId) async {
    final db = await dbHelper.database;
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.update(
      'tasks',
      {'is_trashed': 0, 'trashed_at': null, 'updated_at': now},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  @override
  Future<void> permanentlyDeleteTask(int taskId) async {
    final db = await dbHelper.database;
    final task = await getTaskById(taskId);
    
    // Cancel all reminders first
    final reminders = await getRemindersByTaskId(taskId);
    for (final r in reminders) {
      await notificationService.cancelNotification(r.notificationId);
    }
    await db.delete('tasks', where: 'id = ?', whereArgs: [taskId]);
    
    if (task != null) {
      _syncTaskToFluxFocus(task, 'delete');
    }
  }

  @override
  Future<void> emptyTrash() async {
    final db = await dbHelper.database;
    await db.delete('tasks', where: 'is_trashed = 1');
  }

  // ── Subtasks ────────────────────────────────────────────
  @override
  Future<int> createSubtask(Subtask subtask) async {
    final db = await dbHelper.database;
    return await db.insert('subtasks', subtask.toMap());
  }

  @override
  Future<void> updateSubtask(Subtask subtask) async {
    final db = await dbHelper.database;
    await db.update('subtasks', subtask.toMap(), where: 'id = ?', whereArgs: [subtask.id]);
  }

  @override
  Future<void> deleteSubtask(int subtaskId) async {
    final db = await dbHelper.database;
    await db.delete('subtasks', where: 'id = ?', whereArgs: [subtaskId]);
  }

  @override
  Future<void> toggleSubtaskComplete(int subtaskId) async {
    final db = await dbHelper.database;
    final result = await db.query('subtasks', where: 'id = ?', whereArgs: [subtaskId]);
    if (result.isEmpty) return;
    final current = (result.first['is_completed'] as int) == 1;
    await db.update('subtasks', {'is_completed': current ? 0 : 1}, where: 'id = ?', whereArgs: [subtaskId]);
  }

  @override
  Future<List<Subtask>> getSubtasksByTaskId(int taskId) async {
    final db = await dbHelper.database;
    final maps = await db.query('subtasks', where: 'task_id = ?', whereArgs: [taskId], orderBy: 'sort_order ASC');
    return maps.map((m) => Subtask.fromMap(m)).toList();
  }

  // ── Reminders ───────────────────────────────────────────
  @override
  Future<int> createReminder(Reminder reminder) async {
    final db = await dbHelper.database;
    final id = await db.insert('reminders', reminder.toMap());
    
    // Schedule notification
    final task = await getTaskById(reminder.taskId);
    if (task != null && !task.isCompleted && !task.isTrashed) {
      await notificationService.scheduleNotification(
        id: reminder.notificationId,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: DateTime.fromMillisecondsSinceEpoch(reminder.remindAt),
      );
    }
    return id;
  }

  @override
  Future<void> deleteReminder(int reminderId) async {
    final db = await dbHelper.database;
    final result = await db.query('reminders', where: 'id = ?', whereArgs: [reminderId]);
    if (result.isNotEmpty) {
      final reminder = Reminder.fromMap(result.first);
      await notificationService.cancelNotification(reminder.notificationId);
    }
    await db.delete('reminders', where: 'id = ?', whereArgs: [reminderId]);
  }

  @override
  Future<List<Reminder>> getRemindersByTaskId(int taskId) async {
    final db = await dbHelper.database;
    final maps = await db.query('reminders', where: 'task_id = ?', whereArgs: [taskId], orderBy: 'remind_at ASC');
    return maps.map((m) => Reminder.fromMap(m)).toList();
  }
}
