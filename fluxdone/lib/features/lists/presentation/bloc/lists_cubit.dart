import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/i_list_repository.dart';
import '../../domain/entities.dart';
import 'lists_state.dart';

@injectable
class ListsCubit extends Cubit<ListsState> {
  final IListRepository _repository;

  ListsCubit(this._repository) : super(const ListsState());

  Future<void> loadAll() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final folders = await _repository.getAllFolders();
      final Map<int, List<TaskList>> listsMap = {};
      
      for (final folder in folders) {
        if (folder.id != null) {
          final lists = await _repository.getListsByFolderId(folder.id!);
          listsMap[folder.id!] = lists;
        }
      }
      
      emit(state.copyWith(
        folders: folders,
        listsByFolder: listsMap,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> createFolder(String name) async {
    try {
      final folder = Folder(name: name);
      await _repository.createFolder(folder);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> createList(int folderId, String name, String colorHex) async {
    try {
      final list = TaskList(folderId: folderId, name: name, colorHex: colorHex);
      await _repository.createList(list);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> renameFolder(Folder folder, String newName) async {
    try {
      final updated = Folder(id: folder.id, name: newName, sortOrder: folder.sortOrder);
      await _repository.updateFolder(updated);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> renameList(TaskList list, String newName) async {
    try {
      final updated = TaskList(
        id: list.id,
        folderId: list.folderId,
        name: newName,
        colorHex: list.colorHex,
        sortOrder: list.sortOrder,
      );
      await _repository.updateList(updated);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteFolder(int folderId) async {
    try {
      await _repository.deleteFolder(folderId);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteList(int listId) async {
    try {
      await _repository.deleteList(listId);
      await loadAll();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
