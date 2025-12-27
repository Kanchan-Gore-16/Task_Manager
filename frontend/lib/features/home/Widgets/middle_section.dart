import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_task_manager/features/home/Widgets/task_skeleton.dart';

import '../../task_provider.dart';
import '../task_filter_provider.dart';
import 'bottom_section.dart';

class MiddleSection extends StatelessWidget {
  const MiddleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(child: Column(children: [SearchBar(), TaskList()]));
  }
}

class SearchBar extends ConsumerStatefulWidget {
  const SearchBar({super.key});

  @override
  ConsumerState<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends ConsumerState<SearchBar> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = value.trim().length >= 2 ? value.trim() : null;

      ref.read(taskFilterProvider.notifier).setSearch(query);
      ref.read(taskProvider.notifier).resetPagination();

      ref.read(taskProvider.notifier).fetchTasks(includeSummary: false);
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(taskFilterProvider.notifier).setSearch(null);
    ref.read(taskProvider.notifier).fetchTasks(includeSummary: true);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        decoration: InputDecoration(
          hintText: "Search tasks...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class TaskList extends ConsumerWidget {
  const TaskList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskState = ref.watch(taskProvider);

    if (taskState.loading) {
      return Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: taskState.limit,
          itemBuilder: (_, __) => const TaskSkeleton(),
        ),
      );
    }

    if (taskState.error != null) {
      return Expanded(child: Center(child: Text(taskState.error!)));
    }

    final tasks = taskState.tasks;

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(taskProvider.notifier)
                    .fetchTasks(includeSummary: true);
              },
              child: tasks.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(
                          child: Text(
                            "No tasks found",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];

                        return GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => TaskFormBottomSheet(task: task),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Dismissible(
                              key: ValueKey(task.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              // CONFIRMATION BEFORE DISMISS
                              confirmDismiss: (_) async {
                                return await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete Task"),
                                    content: const Text(
                                      "Are you sure you want to delete this task?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              // DELETE
                              onDismissed: (_) async {
                                try {
                                  await ref
                                      .read(taskProvider.notifier)
                                      .deleteTask(task.id);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Task deleted"),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Delete failed: $e"),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // TITLE
                                    Text(
                                      task.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),

                                    if (task.description != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        task.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],

                                    const SizedBox(height: 8),

                                    // TAGS
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            _Chip(
                                              text: task.category,
                                              color: getCategoryColor(
                                                task.category,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            _Chip(
                                              text: task.priority.toUpperCase(),
                                              color: getPriorityColor(
                                                task.priority,
                                              ),
                                              textColor: Colors.white,
                                            ),
                                          ],
                                        ),
                                        _StatusChip(status: task.status),
                                      ],
                                    ),

                                    // DUE DATE & ASSIGNED
                                    if (task.dueDate != null ||
                                        task.assigned_to != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Row(
                                          children: [
                                            if (task.dueDate != null)
                                              _DueDateWidget(
                                                dueDate: task.dueDate!,
                                                status: task.status,
                                              ),
                                            if (task.dueDate != null &&
                                                task.assigned_to != null)
                                              const SizedBox(width: 12),
                                            if (task.assigned_to != null)
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    size: 14,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    task.assigned_to!,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: taskState.offset == 0
                      ? null
                      : () => ref.read(taskProvider.notifier).previousPage(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text("Previous"),
                ),
                Text(
                  "Page ${(taskState.offset ~/ taskState.limit) + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: taskState.hasMore
                      ? () => ref.read(taskProvider.notifier).nextPage()
                      : null,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text("Next"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Chip({
    required this.text,
    required this.color,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        formatStatus(status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _DueDateWidget extends StatelessWidget {
  final String dueDate;
  final String status;

  const _DueDateWidget({required this.dueDate, required this.status});

  @override
  Widget build(BuildContext context) {
    final overdue = isOverdue(dueDate, status);

    return Row(
      children: [
        Icon(Icons.event, size: 14, color: overdue ? Colors.red : Colors.grey),
        const SizedBox(width: 4),
        Text(
          overdue
              ? "Overdue ${formatDueDate(dueDate)}"
              : "Due ${formatDueDate(dueDate)}",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: overdue ? Colors.red : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

Color getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'finance':
      return Colors.lightBlue.shade100;
    case 'technical':
      return Colors.deepPurpleAccent.shade100;
    case 'safety':
      return Colors.red.shade100;
    case 'scheduling':
      return Colors.deepOrangeAccent.shade100;
    default:
      return Colors.grey.shade200;
  }
}

Color getPriorityColor(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return Colors.red;
    case 'medium':
      return Colors.orange;
    case 'low':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return Colors.orange;
    case 'in_progress':
      return Colors.blue;
    case 'completed':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

String formatStatus(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return 'Pending';
    case 'in_progress':
      return 'In Progress';
    case 'completed':
      return 'Completed';
    default:
      return status;
  }
}

bool isOverdue(String dueDate, String status) {
  if (status.toLowerCase() == 'completed') return false;
  try {
    return DateTime.parse(dueDate).isBefore(DateTime.now());
  } catch (_) {
    return false;
  }
}

String formatDueDate(String isoDate) {
  final date = DateTime.tryParse(isoDate);
  if (date == null) return isoDate;
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return "${date.day.toString().padLeft(2, '0')} "
      "${months[date.month - 1]} ${date.year}";
}
