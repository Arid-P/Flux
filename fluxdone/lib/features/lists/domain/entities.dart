class Folder {
  final int? id;
  final String name;
  final int sortOrder;

  const Folder({
    this.id,
    required this.name,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'sort_order': sortOrder,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] as int,
      name: map['name'] as String,
      sortOrder: map['sort_order'] as int,
    );
  }
}

class TaskList {
  final int? id;
  final int folderId;
  final String name;
  final String colorHex;
  final int sortOrder;

  const TaskList({
    this.id,
    required this.folderId,
    required this.name,
    required this.colorHex,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'folder_id': folderId,
      'name': name,
      'color_hex': colorHex,
      'sort_order': sortOrder,
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory TaskList.fromMap(Map<String, dynamic> map) {
    return TaskList(
      id: map['id'] as int,
      folderId: map['folder_id'] as int,
      name: map['name'] as String,
      colorHex: map['color_hex'] as String,
      sortOrder: map['sort_order'] as int,
    );
  }
}

class Section {
  final int? id;
  final int listId;
  final String name;
  final int sortOrder;

  const Section({
    this.id,
    required this.listId,
    required this.name,
    this.sortOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'list_id': listId,
      'name': name,
      'sort_order': sortOrder,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'] as int,
      listId: map['list_id'] as int,
      name: map['name'] as String,
      sortOrder: map['sort_order'] as int,
    );
  }
}
