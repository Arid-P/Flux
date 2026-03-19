class Task {
  final int? id;
  final int listId;
  final int? sectionId;
  final String title;
  final String? descriptionMd;
  final int taskDate; // epoch ms
  final int? startTime; // epoch ms
  final int? endTime; // epoch ms
  final bool isCompleted;
  final int? completedAt;
  final bool isTrashed;
  final int? trashedAt;
  final bool isPinned;
  final int priority; // 0=none, 1=low, 2=medium, 3=high
  final String? recurrenceRule;
  final int? recurrenceParentId;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;

  const Task({
    this.id,
    required this.listId,
    this.sectionId,
    required this.title,
    this.descriptionMd,
    required this.taskDate,
    this.startTime,
    this.endTime,
    this.isCompleted = false,
    this.completedAt,
    this.isTrashed = false,
    this.trashedAt,
    this.isPinned = false,
    this.priority = 0,
    this.recurrenceRule,
    this.recurrenceParentId,
    this.sortOrder = 0,
    int? createdAt,
    int? updatedAt,
  })  : createdAt = createdAt ?? 0,
        updatedAt = updatedAt ?? 0;

  Map<String, dynamic> toMap() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return {
      if (id != null) 'id': id,
      'list_id': listId,
      'section_id': sectionId,
      'title': title,
      'description_md': descriptionMd,
      'task_date': taskDate,
      'start_time': startTime,
      'end_time': endTime,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt,
      'is_trashed': isTrashed ? 1 : 0,
      'trashed_at': trashedAt,
      'is_pinned': isPinned ? 1 : 0,
      'priority': priority,
      'recurrence_rule': recurrenceRule,
      'recurrence_parent_id': recurrenceParentId,
      'sort_order': sortOrder,
      'created_at': createdAt == 0 ? now : createdAt,
      'updated_at': now,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int,
      listId: map['list_id'] as int,
      sectionId: map['section_id'] as int?,
      title: map['title'] as String,
      descriptionMd: map['description_md'] as String?,
      taskDate: map['task_date'] as int,
      startTime: map['start_time'] as int?,
      endTime: map['end_time'] as int?,
      isCompleted: (map['is_completed'] as int) == 1,
      completedAt: map['completed_at'] as int?,
      isTrashed: (map['is_trashed'] as int) == 1,
      trashedAt: map['trashed_at'] as int?,
      isPinned: (map['is_pinned'] as int) == 1,
      priority: map['priority'] as int,
      recurrenceRule: map['recurrence_rule'] as String?,
      recurrenceParentId: map['recurrence_parent_id'] as int?,
      sortOrder: map['sort_order'] as int,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  Task copyWith({
    int? id,
    int? listId,
    int? sectionId,
    String? title,
    String? descriptionMd,
    int? taskDate,
    int? startTime,
    int? endTime,
    bool? isCompleted,
    int? completedAt,
    bool? isTrashed,
    int? trashedAt,
    bool? isPinned,
    int? priority,
    String? recurrenceRule,
    int? recurrenceParentId,
    int? sortOrder,
  }) {
    return Task(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      sectionId: sectionId ?? this.sectionId,
      title: title ?? this.title,
      descriptionMd: descriptionMd ?? this.descriptionMd,
      taskDate: taskDate ?? this.taskDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      isTrashed: isTrashed ?? this.isTrashed,
      trashedAt: trashedAt ?? this.trashedAt,
      isPinned: isPinned ?? this.isPinned,
      priority: priority ?? this.priority,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      recurrenceParentId: recurrenceParentId ?? this.recurrenceParentId,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }
}

class Subtask {
  final int? id;
  final int taskId;
  final String title;
  final bool isCompleted;
  final int sortOrder;

  const Subtask({
    this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
      'sort_order': sortOrder,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(
      id: map['id'] as int,
      taskId: map['task_id'] as int,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      sortOrder: map['sort_order'] as int,
    );
  }
}

class Reminder {
  final int? id;
  final int taskId;
  final int remindAt;
  final int? offsetMinutes;
  final int notificationId;

  const Reminder({
    this.id,
    required this.taskId,
    required this.remindAt,
    this.offsetMinutes,
    required this.notificationId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'task_id': taskId,
      'remind_at': remindAt,
      'offset_minutes': offsetMinutes,
      'notification_id': notificationId,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int,
      taskId: map['task_id'] as int,
      remindAt: map['remind_at'] as int,
      offsetMinutes: map['offset_minutes'] as int?,
      notificationId: map['notification_id'] as int,
    );
  }
}
