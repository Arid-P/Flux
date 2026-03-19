class Habit {
  final int? id;
  final String name;
  final String colorHex;
  final String iconIdentifier;
  final String frequencyRule;
  final int targetCount;
  final int? reminderTime;
  final int currentStreak;
  final int longestStreak;
  final bool isActive;
  final int createdAt;

  const Habit({
    this.id,
    required this.name,
    required this.colorHex,
    this.iconIdentifier = 'star',
    required this.frequencyRule,
    this.targetCount = 1,
    this.reminderTime,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isActive = true,
    int? createdAt,
  }) : createdAt = createdAt ?? 0;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'color_hex': colorHex,
      'icon_identifier': iconIdentifier,
      'frequency_rule': frequencyRule,
      'target_count': targetCount,
      'reminder_time': reminderTime,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt == 0 ? DateTime.now().millisecondsSinceEpoch : createdAt,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as int,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      iconIdentifier: map['icon_identifier'] as String,
      frequencyRule: map['frequency_rule'] as String,
      targetCount: map['target_count'] as int,
      reminderTime: map['reminder_time'] as int?,
      currentStreak: map['current_streak'] as int,
      longestStreak: map['longest_streak'] as int,
      isActive: (map['is_active'] as int) == 1,
      createdAt: map['created_at'] as int,
    );
  }
}

class HabitCompletion {
  final int? id;
  final int habitId;
  final int completedDate; // epoch ms of start-of-day
  final int completionCount;

  const HabitCompletion({
    this.id,
    required this.habitId,
    required this.completedDate,
    this.completionCount = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'habit_id': habitId,
      'completed_date': completedDate,
      'completion_count': completionCount,
    };
  }

  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'] as int,
      habitId: map['habit_id'] as int,
      completedDate: map['completed_date'] as int,
      completionCount: map['completion_count'] as int,
    );
  }
}
