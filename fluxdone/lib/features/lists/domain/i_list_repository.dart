import 'entities.dart';

abstract class IListRepository {
  Future<List<Folder>> getAllFolders();
  Future<List<TaskList>> getListsByFolderId(int folderId);
  Future<List<Section>> getSectionsByListId(int listId);
  Future<int> createFolder(Folder folder);
  Future<int> createList(TaskList list);
  Future<int> createSection(Section section);
  Future<void> updateFolder(Folder folder);
  Future<void> updateList(TaskList list);
  Future<void> deleteFolder(int id);
  Future<void> deleteList(int id);
  Future<String> getColorHexByListId(int id);
  Future<String> getListNameById(int id);
}
