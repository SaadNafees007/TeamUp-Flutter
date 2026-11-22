import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/empty_state.dart';
import '../../team/providers/team_provider.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamState = ref.watch(teamProvider);
    final tasks = teamState.tasks;
    final completedCount = tasks.where((t) => t.isCompleted).length;
    final progress = tasks.isEmpty ? 0.0 : (completedCount / tasks.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Task Checklist'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_task_rounded,
              color: AppColors.primaryIndigo,
            ),
            tooltip: 'Add Task',
            onPressed: () => _showAddTaskDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Milestone Completion',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$completedCount of ${tasks.length} Completed',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryIndigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.slateLight,
                    color: AppColors.accentEmerald,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: tasks.isEmpty
                ? EmptyState(
                    icon: Icons.checklist_rounded,
                    title: 'No Tasks Created Yet',
                    message:
                        'Add project tasks and assign them to your teammates to track project execution.',
                    buttonText: 'Add First Task',
                    onButtonPressed: () => _showAddTaskDialog(context),
                  )
                : ListView.builder(
                    itemCount: tasks.length,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppColors.statusRejected,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          ref.read(teamProvider.notifier).deleteTask(task.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Task deleted.')),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: task.isCompleted
                                  ? AppColors.accentEmerald.withValues(alpha: 0.3)
                                  : AppColors.border,
                            ),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: task.isCompleted,
                              activeColor: AppColors.accentEmerald,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (_) {
                                ref
                                    .read(teamProvider.notifier)
                                    .toggleTask(task.id);
                              },
                            ),
                            title: Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: task.isCompleted
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                              ),
                            ),
                            subtitle: task.description.isNotEmpty
                                ? Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: task.isCompleted
                                          ? AppColors.textMuted
                                          : AppColors.textSecondary,
                                    ),
                                  )
                                : null,
                            trailing: Text(
                              DateFormat('MMM d').format(task.createdAt),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryIndigo,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTaskDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    _taskController.clear();
    _descController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create Project Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _taskController,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                hintText: 'e.g. Design Entity Relationship Diagram',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Optional Description',
                hintText: 'Deliverables or details...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = _taskController.text.trim();
              if (title.isNotEmpty) {
                ref
                    .read(teamProvider.notifier)
                    .addTask(title: title, description: _descController.text);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
