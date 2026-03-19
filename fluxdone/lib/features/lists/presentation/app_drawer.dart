import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/theme_tokens.dart';
import '../../../core/utils/hex_color.dart';
import '../domain/entities.dart';
import 'bloc/lists_cubit.dart';
import 'bloc/lists_state.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Set<int> expandedFolders = {};

  @override
  void initState() {
    super.initState();
    // Load folders & lists from database on first open
    context.read<ListsCubit>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Drawer(
      backgroundColor: tokens.surface,
      elevation: 16,
      width: MediaQuery.of(context).size.width > 400
          ? 320
          : MediaQuery.of(context).size.width * 0.8,
      child: BlocBuilder<ListsCubit, ListsState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(tokens),
              Divider(height: 1, color: tokens.divider),
              Expanded(
                child: state.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _buildSectionLabel('LISTS', tokens),
                          if (state.folders.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Text(
                                'No folders yet. Tap "+" below to create one.',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: tokens.textSecondary),
                              ),
                            ),
                          ...state.folders
                              .map((f) => _buildFolderRow(f, state, tokens)),
                          Divider(height: 1, color: tokens.divider),
                          _buildSectionLabel('SMART LISTS', tokens),
                          _buildSmartListRow(
                              'Today', Icons.today_outlined, 0, tokens),
                          _buildSmartListRow(
                              'Tomorrow', Icons.event_outlined, 0, tokens),
                          _buildSmartListRow('Upcoming',
                              Icons.date_range_outlined, 0, tokens),
                          _buildSmartListRow(
                              'All', Icons.list_alt_outlined, 0, tokens),
                          _buildSmartListRow('Completed',
                              Icons.check_circle_outline, 0, tokens),
                          _buildSmartListRow(
                              'Trash', Icons.delete_outline, 0, tokens),
                          const SizedBox(height: 8),
                          _buildAddButton(tokens),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
              Divider(height: 1, color: tokens.divider),
              _buildSettingsShortcut(context, tokens),
            ],
          );
        },
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────
  Widget _buildHeader(ThemeTokens tokens) {
    return Container(
      height: 72,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      alignment: Alignment.centerLeft,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: tokens.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'FluxDone',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: tokens.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Label ────────────────────────────────────────
  Widget _buildSectionLabel(String text, ThemeTokens tokens) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: tokens.textSecondary,
        ),
      ),
    );
  }

  // ── Folder Row ───────────────────────────────────────────
  Widget _buildFolderRow(Folder folder, ListsState state, ThemeTokens tokens) {
    final isExpanded = expandedFolders.contains(folder.id);
    final folderLists = state.listsByFolder[folder.id] ?? [];

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                expandedFolders.remove(folder.id);
              } else {
                expandedFolders.add(folder.id!);
              }
            });
          },
          onLongPress: () => _showFolderContextMenu(folder),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.folder_outlined,
                    size: 20, color: tokens.textSecondary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    folder.name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: tokens.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text('${folderLists.length}',
                    style:
                        TextStyle(fontSize: 12, color: tokens.textSecondary)),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.expand_more,
                      size: 16, color: tokens.textSecondary),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: isExpanded
              ? Column(
                  children:
                      folderLists.map((l) => _buildListRow(l, tokens)).toList(),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── List Row ─────────────────────────────────────────────
  Widget _buildListRow(TaskList list, ThemeTokens tokens) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // close drawer
        context.go('/tasks/${list.id}');
      },
      onLongPress: () => _showListContextMenu(list),
      child: Container(
        height: 44,
        padding: const EdgeInsets.only(left: 32, right: 16),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
                width: 3, color: HexColor.fromHex(list.colorHex)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: HexColor.fromHex(list.colorHex),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                list.name,
                style: TextStyle(fontSize: 14, color: tokens.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Smart List Row ───────────────────────────────────────
  Widget _buildSmartListRow(
      String name, IconData icon, int count, ThemeTokens tokens) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        // Navigate to smart list view
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: tokens.textSecondary),
            const SizedBox(width: 16),
            Text(name,
                style: TextStyle(fontSize: 14, color: tokens.textPrimary)),
            const Spacer(),
            Text(count.toString(),
                style: TextStyle(fontSize: 12, color: tokens.textSecondary)),
          ],
        ),
      ),
    );
  }

  // ── Add Button ───────────────────────────────────────────
  Widget _buildAddButton(ThemeTokens tokens) {
    return InkWell(
      onTap: () => _showAddDialog(),
      child: Container(
        height: 44,
        padding: const EdgeInsets.only(left: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(Icons.add, size: 20, color: tokens.primary),
            const SizedBox(width: 16),
            Text(
              'Add List or Folder',
              style: TextStyle(fontSize: 14, color: tokens.primary),
            ),
          ],
        ),
      ),
    );
  }

  // ── Settings Shortcut ────────────────────────────────────
  Widget _buildSettingsShortcut(BuildContext context, ThemeTokens tokens) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        context.go('/settings');
      },
      child: SafeArea(
        top: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.settings_outlined,
                  size: 20, color: tokens.textSecondary),
              const SizedBox(width: 16),
              Text('Settings',
                  style: TextStyle(fontSize: 14, color: tokens.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Dialogs ──────────────────────────────────────────────
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create New'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('New Folder'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreateFolderDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('New List'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreateListDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateFolderDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('New Folder'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(hintText: 'Folder name'),
            onSubmitted: (_) {
              if (controller.text.trim().isNotEmpty) {
                context.read<ListsCubit>().createFolder(controller.text.trim());
                Navigator.pop(ctx);
              }
            },
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context
                      .read<ListsCubit>()
                      .createFolder(controller.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateListDialog() {
    final controller = TextEditingController();
    final cubit = context.read<ListsCubit>();
    final folders = cubit.state.folders;
    int? selectedFolderId = folders.isNotEmpty ? folders.first.id : null;
    String selectedColor = '2E7D32';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setDialogState) {
          return AlertDialog(
            title: const Text('New List'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  maxLength: 50,
                  decoration: const InputDecoration(hintText: 'List name'),
                ),
                const SizedBox(height: 8),
                DropdownButton<int>(
                  isExpanded: true,
                  value: selectedFolderId,
                  hint: const Text('Select Folder'),
                  items: folders.map((f) {
                    return DropdownMenuItem(value: f.id, child: Text(f.name));
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedFolderId = v),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    '2E7D32', '1565C0', '43A047', 'FB8C00',
                    'E64A19', 'E53935', '576481', '7B1FA2',
                    '00838F', 'F57F17', '5E35B1', '546E7A',
                  ].map((hex) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = hex),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: HexColor.fromHex(hex),
                          shape: BoxShape.circle,
                          border: selectedColor == hex
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty &&
                      selectedFolderId != null) {
                    cubit.createList(
                        selectedFolderId!, controller.text.trim(), selectedColor);
                    Navigator.pop(ctx);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showFolderContextMenu(Folder folder) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename folder'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRenameFolderDialog(folder);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete folder',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmation(
                    title: 'Delete folder?',
                    body:
                        'This will permanently delete the folder and all its lists and tasks. This cannot be undone.',
                    onDelete: () =>
                        context.read<ListsCubit>().deleteFolder(folder.id!),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showListContextMenu(TaskList list) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename list'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showRenameListDialog(list);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete list',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteConfirmation(
                    title: 'Delete list?',
                    body:
                        'This will permanently delete the list and all its tasks. This cannot be undone.',
                    onDelete: () =>
                        context.read<ListsCubit>().deleteList(list.id!),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRenameFolderDialog(Folder folder) {
    final controller = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Rename folder'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context
                      .read<ListsCubit>()
                      .renameFolder(folder, controller.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showRenameListDialog(TaskList list) {
    final controller = TextEditingController(text: list.name);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Rename list'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 50,
            textInputAction: TextInputAction.done,
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context
                      .read<ListsCubit>()
                      .renameList(list, controller.text.trim());
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation({
    required String title,
    required String body,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.pop(ctx);
              },
              child:
                  const Text('Delete', style: TextStyle(color: Color(0xFFE53935))),
            ),
          ],
        );
      },
    );
  }
}
