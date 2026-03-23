import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../domain/focus_block_request.dart';
import '../../../core/utils/logger.dart';
import '../../../core/di/injection.dart';
import '../../tasks/domain/i_task_repository.dart';
import '../../tasks/domain/entities.dart';
import '../../lists/domain/i_list_repository.dart';
import '../../lists/domain/entities.dart' as list_entities;

@lazySingleton
class FluxFocusBridgeService {
  static const _channel = MethodChannel('com.fluxfoxus/fd_integration');
  
  final _logger = Logger();

  Future<void> init() async {
    _logger.info('Initializing FluxFocusBridgeService');
    
    // 1. Ensure 'FF' section exists in the first available list
    await _ensureFFSectionExists();

    // 2. Set method call handler
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<void> _ensureFFSectionExists() async {
    try {
      final listRepo = getIt<IListRepository>();
      final lists = await listRepo.getAllFolders().then((folders) async {
        if (folders.isEmpty) {
          // Create a default folder and list if none exist
          final folderId = await listRepo.createFolder(list_entities.Folder(
            name: 'My Tasks',
            sort_order: 0,
            created_at: DateTime.now().millisecondsSinceEpoch,
            updated_at: DateTime.now().millisecondsSinceEpoch,
          ));
          final listId = await listRepo.createList(list_entities.TaskList(
            folderId: folderId,
            name: 'General',
            colorHex: '2E7D32',
            sort_order: 0,
            created_at: DateTime.now().millisecondsSinceEpoch,
            updated_at: DateTime.now().millisecondsSinceEpoch,
          ));
          return [listId];
        }
        // Get lists for the first folder
        final folderLists = await listRepo.getListsByFolderId(folders.first.id!);
        if (folderLists.isEmpty) {
           final listId = await listRepo.createList(list_entities.TaskList(
            folderId: folders.first.id!,
            name: 'General',
            colorHex: '2E7D32',
            sort_order: 0,
            created_at: DateTime.now().millisecondsSinceEpoch,
            updated_at: DateTime.now().millisecondsSinceEpoch,
          ));
          return [listId];
        }
        return folderLists.map((l) => l.id!).toList();
      });

      if (lists.isNotEmpty) {
        final firstListId = lists.first;
        final sections = await listRepo.getSectionsByListId(firstListId);
        final hasFF = sections.any((s) => s.name == 'FF');
        
        if (!hasFF) {
          await listRepo.createSection(list_entities.Section(
            listId: firstListId,
            name: 'FF',
            sortOrder: 99, // Place at the end
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
          _logger.info('Created FF section in list $firstListId');
        }
      }
    } catch (e) {
      _logger.error('Error ensuring FF section: $e');
    }
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'createTask':
        return await _handleCreateTask(call.arguments);
      default:
        _logger.warning('Unknown method called from FluxFocus: ${call.method}');
        throw PlatformException(code: 'unsupported', message: 'Method not implemented');
    }
  }

  Future<bool> _handleCreateTask(dynamic arguments) async {
    try {
      final payload = jsonDecode(arguments['payload'] as String);
      final request = FocusBlockRequest.fromJson(payload);
      
      final taskRepo = getIt<ITaskRepository>();
      final listRepo = getIt<IListRepository>();
      
      // Get the list and section
      final folders = await listRepo.getAllFolders();
      if (folders.isEmpty) return false;
      final lists = await listRepo.getListsByFolderId(folders.first.id!);
      if (lists.isEmpty) return false;
      final listId = lists.first.id!;
      
      final sections = await listRepo.getSectionsByListId(listId);
      final ffSection = sections.firstWhere((s) => s.name == 'FF', orElse: () => sections.first);
      
      final task = Task(
        listId: listId,
        sectionId: ffSection.id,
        title: request.taskName,
        taskDate: request.startTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        startTime: request.startTime?.millisecondsSinceEpoch,
        endTime: request.endTime?.millisecondsSinceEpoch,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      
      await taskRepo.createTask(task);
      _logger.info('Created task from FluxFocus: ${request.taskName}');
      return true;
    } catch (e) {
      _logger.error('Error handling createTask from FluxFocus: $e');
      return false;
    }
  }

  Future<void> sendFocusBlockRequest(FocusBlockRequest request) async {
    try {
      final json = jsonEncode(request.toJson());
      await _channel.invokeMethod('onFocusBlockSync', {'payload': json});
      _logger.info('Sent FocusBlockRequest: ${request.action} for task ${request.taskId}');
    } on PlatformException catch (e) {
      _logger.error('Failed to send FocusBlockRequest: ${e.message}');
    }
  }

  void setMethodCallHandler(Future<dynamic> Function(MethodCall) handler) {
    _channel.setMethodCallHandler(handler);
  }
}
