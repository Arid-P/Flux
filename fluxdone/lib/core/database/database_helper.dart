import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DatabaseHelper {
  static const String _dbName = 'fluxdone_v2.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    final batch = db.batch();

    // 5.2 Table: folders
    batch.execute('''
      CREATE TABLE folders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // 5.3 Table: task_lists
    batch.execute('''
      CREATE TABLE task_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES folders(id) ON DELETE CASCADE
      )
    ''');

    // 5.4 Table: sections
    batch.execute('''
      CREATE TABLE sections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (list_id) REFERENCES task_lists(id) ON DELETE CASCADE
      )
    ''');

    // 5.5 Table: tasks
    batch.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        section_id INTEGER,
        title TEXT NOT NULL,
        description_md TEXT,
        task_date INTEGER NOT NULL,
        start_time INTEGER,
        end_time INTEGER,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at INTEGER,
        is_trashed INTEGER NOT NULL DEFAULT 0,
        trashed_at INTEGER,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        priority INTEGER NOT NULL DEFAULT 0,
        recurrence_rule TEXT,
        recurrence_parent_id INTEGER,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (list_id) REFERENCES task_lists(id) ON DELETE CASCADE,
        FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE SET NULL,
        FOREIGN KEY (recurrence_parent_id) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

    // 5.6 Table: subtasks
    batch.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

    // 5.7 Table: reminders
    batch.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        remind_at INTEGER NOT NULL,
        offset_minutes INTEGER,
        notification_id INTEGER NOT NULL,
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
      )
    ''');

    // 5.8 Table: habits
    batch.execute('''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color_hex TEXT NOT NULL,
        icon_identifier TEXT NOT NULL DEFAULT 'star',
        frequency_rule TEXT NOT NULL,
        target_count INTEGER NOT NULL DEFAULT 1,
        reminder_time INTEGER,
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL
      )
    ''');

    // 5.9 Table: habit_completions
    // UNIQUE constraint on habit_id + completed_date
    batch.execute('''
      CREATE TABLE habit_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        habit_id INTEGER NOT NULL,
        completed_date INTEGER NOT NULL,
        completion_count INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (habit_id) REFERENCES habits(id) ON DELETE CASCADE,
        UNIQUE(habit_id, completed_date)
      )
    ''');

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handling future schema upgrades
  }
}
