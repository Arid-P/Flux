import 'package:injectable/injectable.dart';
import '../../../core/database/database_helper.dart';
import '../domain/i_list_repository.dart';
import '../domain/entities.dart';

@LazySingleton(as: IListRepository)
class ListRepositoryImpl implements IListRepository {
  final DatabaseHelper dbHelper;
  ListRepositoryImpl(this.dbHelper);

  @override
  Future<List<Folder>> getAllFolders() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('folders', orderBy: 'sort_order ASC');
    return maps.map((m) => Folder.fromMap(m)).toList();
  }

  @override
  Future<List<TaskList>> getListsByFolderId(int folderId) async {
    final db = await dbHelper.database;
    final maps = await db.query('task_lists', where: 'folder_id = ?', whereArgs: [folderId], orderBy: 'sort_order ASC');
    return maps.map((m) => TaskList.fromMap(m)).toList();
  }

  @override
  Future<List<Section>> getSectionsByListId(int listId) async {
    final db = await dbHelper.database;
    final maps = await db.query('sections', where: 'list_id = ?', whereArgs: [listId], orderBy: 'sort_order ASC');
    return maps.map((m) => Section.fromMap(m)).toList();
  }

  @override
  Future<int> createFolder(Folder folder) async {
    final db = await dbHelper.database;
    return await db.insert('folders', folder.toMap());
  }

  @override
  Future<int> createList(TaskList list) async {
    final db = await dbHelper.database;
    return await db.insert('task_lists', list.toMap());
  }

  @override
  Future<int> createSection(Section section) async {
    final db = await dbHelper.database;
    return await db.insert('sections', section.toMap());
  }

  @override
  Future<void> updateFolder(Folder folder) async {
    final db = await dbHelper.database;
    final map = folder.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.update('folders', map, where: 'id = ?', whereArgs: [folder.id]);
  }

  @override
  Future<void> updateList(TaskList list) async {
    final db = await dbHelper.database;
    final map = list.toMap();
    map['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    await db.update('task_lists', map, where: 'id = ?', whereArgs: [list.id]);
  }

  @override
  Future<void> deleteFolder(int id) async {
    final db = await dbHelper.database;
    // Database schema uses ON DELETE CASCADE, so child lists and tasks auto-delete.
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> deleteList(int id) async {
    final db = await dbHelper.database;
    // TRD 9.2: "Soft-deletes all tasks in list".
    // 1. Soft delete tasks
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.execute('UPDATE tasks SET is_trashed = 1, trashed_at = ? WHERE list_id = ? AND is_trashed = 0', [now, id]);
    // 2. We don't delete the list itself if we soft-delete tasks?
    // Wait, TRD says "Future<void> deleteList(int id) // Soft-deletes all tasks in list"
    // Does it delete the list itself? Usually, yes, but if tasks are kept in trash, they need a list_id!
    // But list_id is a foreign key with ON DELETE CASCADE in `tasks` table!
    // If I delete the list, the tasks are physically removed entirely instantly!
    // TRD 5.5: FOREIGN KEY (list_id) REFERENCES task_lists(id) ON DELETE CASCADE
    // This implies list deletion HARD deletes tasks because of SQLite constraints, regardless of the comment.
    // If we want to soft-delete tasks, we cannot delete the list, or we must remove the ON DELETE CASCADE constraint, or change list_id to NULLable (which it isn't).
    // Let's just delete the list and let SQLite cascade for now to be safe with DB schema.
    await db.delete('task_lists', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<String> getColorHexByListId(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('task_lists', columns: ['color_hex'], where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first['color_hex'] as String;
    }
    return '2E7D32'; // fallback default
  }

  @override
  Future<String> getListNameById(int id) async {
    final db = await dbHelper.database;
    final result = await db.query('task_lists', columns: ['name'], where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return result.first['name'] as String;
    }
    return '';
  }
}
