import 'package:equatable/equatable.dart';
import '../../domain/entities.dart';

class ListsState extends Equatable {
  final List<Folder> folders;
  final Map<int, List<TaskList>> listsByFolder;
  final bool isLoading;
  final String? error;

  const ListsState({
    this.folders = const [],
    this.listsByFolder = const {},
    this.isLoading = false,
    this.error,
  });

  ListsState copyWith({
    List<Folder>? folders,
    Map<int, List<TaskList>>? listsByFolder,
    bool? isLoading,
    String? error,
  }) {
    return ListsState(
      folders: folders ?? this.folders,
      listsByFolder: listsByFolder ?? this.listsByFolder,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [folders, listsByFolder, isLoading, error];
}
